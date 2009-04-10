#
#  Perl code for generating LLVM assembly from ETC assembly
#  Copyright (C) 2009 Carl Ritson <cgr@kent.ac.uk>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

package Transputer::LLVM;

use strict;
use vars qw($GRAPH);
use Data::Dumper;

$GRAPH = {
	'J' 		=> { 'in' => 3, 
			'generator' => \&gen_j },
	'LDLP'		=> { 'out' => 1, 
			'generator' => \&gen_ldlp },
	'LDNL'		=> { 'in' => 1, 'out' => 1, 
			'generator' => \&gen_ldnl },
	'LDC'		=> { 'out' => 1, 
			'generator' => \&gen_ldc },
	'LDNLP'		=> { 'in' => 1, 'out' => 1, 
			'generator' => \&gen_ldnlp },
	'LDL'		=> { 'out' => 1, 
			'generator' => \&gen_ldl },
	'ADC'		=> { 'in' => 1, 'out' => 1, 
			'generator' => \&gen_adc },
	'CALL'		=> { 'in' => 3, 'out' => 0, 'vstack' => 1, 
			'generator' => \&gen_call }, # actually out is 3
	'CJ'		=> { 'in' => 3, 'out' => 2, 
			'generator' => \&gen_cj },
	'AJW'		=> { 'wptr' => 1, 
			'generator' => \&gen_ajw },
	'EQC'		=> { 'in' => 1, 'out' => 1,
			'generator' => \&gen_eqc },
	'STL'		=> { 'in' => 1, 
			'generator' => \&gen_stl },
	'STNL'		=> { 'in' => 2, 
			'generator' => \&gen_stnl },
	'REV'		=> { 'in' => 2, 'out' => 2,
			'generator' => \&gen_rev },
	'LB'		=> { 'in' => 1, 'out' => 1 },
	'BSUB'		=> { 'in' => 2, 'out' => 1 },
	'ENDP'		=> { 'in' => 1 },
	'DIFF'		=> { 'in' => 2, 'out' => 1,
			'generator' => \&gen_diff },
	'ADD'		=> { 'in' => 2, 'out' => 1, 
			'generator' => \&gen_add },
	'GCALL'		=> { 'in' => 3, 'vstack' => 1 }, # check
	'IN'		=> { 'in' => 3 },
	'PROD'		=> { 'in' => 2, 'out' => 1,
			'generator' => \&gen_prod },
	'GT'		=> { 'in' => 2, 'out' => 1,
			'generator' => \&gen_gt },
	'WSUB'		=> { 'in' => 2, 'out' => 1 },
	'OUT'		=> { 'in' => 3 },
	'SUB'		=> { 'in' => 2, 'out' => 1,
			'generator' => \&gen_sub },
	'STARTP'	=> { 'in' => 3, 'vstack' => 1 },
	'OUTBYTE'	=> { 'in' => 2, 'vstack' => 1 },
	'OUTWORD'	=> { 'in' => 2, 'vstack' => 1 },
	'SETERR'	=> { 'in' => 1, 'vstack' => 1 },
	'MRELEASEP'	=> { 'in' => 1, 'vstack' => 1 },
	'CSUB0'		=> { 'in' => 2, 'out' => 1,
			'generator' => \&gen_csub0 },
	'EXTVRFY' 	=> { 'in' => 2 },
	'STOPP'		=> { 'vstack' => 1 },
	'LADD'		=> { 'in' => 3, 'out' => 1 },
	'NORM'		=> { 'in' => 3, 'out' => 3 },
	'LDIV'		=> { 'in' => 3, 'out' => 2 },
	'REM'		=> { 'in' => 2, 'out' => 2 },
	'RET'		=> {
			'generator' => \&gen_ret },
	'LDTIMER'	=> { 'out' => 1, 'vstack' => 1 },
	'TIN'		=> { 'in' => 1, 'vstack' => 1 },
	'DIV'		=> { 'in' => 2, 'out' => 2 },
	'DIST'		=> { 'in' => 3, 'out' => 1, 'vstack' => 1 },
	'DISS'		=> { 'in' => 2, 'out' => 1, 'vstack' => 1 },
	'LMUL'		=> { 'in' => 3, 'out' => 2 },
	'NOT'		=> { 'in' => 1, 'out' => 1,
			'generator' => \&gen_not },
	'XOR'		=> { 'in' => 2, 'out' => 1,
			'generator' => \&gen_xor },
	'LSHR'		=> { 'in' => 3, 'out' => 2 },
	'LSHL'		=> { 'in' => 3, 'out' => 2 },
	'LSUM'		=> { 'in' => 3, 'out' => 2 },
	'LSUB'		=> { 'in' => 3, 'out' => 2 },
	'RUNP'		=> { 'in' => 1, 'vstack' => 1 },
	'SB'		=> { 'in' => 2 },
	'GAJW'		=> { 'in' => 1, 'out' => 1, 'wptr' => 1 },
	'SHR'		=> { 'in' => 2, 'out' => 1,
			'generator' => \&gen_shr },
	'SHL'		=> { 'in' => 2, 'out' => 1,
			'generator' => \&gen_shl },
	'MINT'		=> { 'out' => 1,
			'generator' => \&gen_mint },
	'AND'		=> { 'in' => 2, 'out' => 1,
			'generator' => \&gen_and },
	'ENBT'		=> { 'in' => 2, 'out' => 1, 'vstack' => 1 },
	'ENBC'		=> { 'in' => 2, 'out' => 1, 'vstack' => 1 },
	'ENBS'		=> { 'in' => 1, 'out' => 1, 'vstack' => 1 },
	'MOVE'		=> { 'in' => 3 },
	'OR'		=> { 'in' => 2, 'out' => 1,
			'generator' => \&gen_or },
	'LDIFF'		=> { 'in' => 3, 'out' => 2 },
	'SUM'		=> { 'in' => 2, 'out' => 1,
			'generator' => \&gen_sum },
	'MUL'		=> { 'in' => 2, 'out' => 1,
			'generator' => \&gen_mul },
	'DUP'		=> { 'in' => 1, 'out' => 2, 
			'generator' => \&gen_dup },
	'EXTIN'		=> { 'in' => 3, 'vstack' => 1 },
	'EXTOUT'	=> { 'in' => 3, 'vstack' => 1 },
	'POSTNORMSN'	=> { 'in' => 3, 'out' => 3 },
	'ROUNDSN'	=> { 'in' => 3, 'out' => 1 },
	'ENBC3'		=> { 'in' => 3, 'out' => 1, 'vstack' => 1 },
	'LDINF'		=> { 'out' => 1 },
	'POP'		=> { 'in' => 1,
			'generator' => \&gen_nop },
	'WSUBDB'	=> { 'in' => 2, 'out' => 1 },
	'FPLDNLDBI'	=> { 'in' => 2, 'fout' => 1 },
	'FPCHKERR'	=> { 'vstack' => 1 },
	'FPSTNLDB'	=> { 'in' => 1, 'fin' => 1 },
	'FPLDNLSNI'	=> { 'in' => 2, 'fout' => 1 },
	'FPADD'		=> { 'fin' => 2, 'fout' => 1 },
	'FPSTNLSN'	=> { 'in' => 1, 'fin' => 1 },
	'FPSUB'		=> { 'fin' => 2, 'fout' => 1 },
	'FPLDNLDB'	=> { 'in' => 1, 'fout' => 1 },
	'FPMUL'		=> { 'fin' => 2, 'fout' => 1 },
	'FPDIV'		=> { 'fin' => 2, 'fout' => 1 },
	'FPLDNLSN'	=> { 'in' => 1, 'fout' => 1 },
	'FPNAN'		=> { 'fin' => 1, 'fout' => 1, 'out' => 1 },
	'FPORDERED'	=> { 'fin' => 2, 'fout' => 2, 'out' => 1 },
	'FPNOTFINITE'	=> { 'fin' => 1, 'fout' => 1, 'out' => 1 },
	'FPGT'		=> { 'fin' => 2, 'out' => 1 },
	'FPEQ'		=> { 'fin' => 2, 'out' => 1 },
	'FPI32TOR32'	=> { 'in' => 1, 'fout' => 1 },
	'FPI32TOR64'	=> { 'in' => 1, 'fout' => 1 },
	'ENBT3'		=> { 'in' => 3, 'out' => 1, 'vstack' => 1 },
	'FPB32TOR64'	=> { 'in' => 1, 'fout' => 1 },
	'FPRTOI32'	=> { 'fin' => 1, 'fout' => 1 },
	'FPSTNLI32'	=> { 'in' => 1, 'fin' => 1 },
	'FPLDZEROSN'	=> { 'fout' => 1 },
	'FPLDZERODB'	=> { 'fout' => 1 },
	'FPINT'		=> { 'fin' => 1, 'fout' => 1 },
	'GETPRI'	=> { 'out' => 1, 'vstack' => 1 },
	'FPDUP'		=> { 'fin' => 1, 'fout' => 2 },
	'FPREV'		=> { 'fin' => 2, 'fout' => 2 },
	'SETPRI'	=> { 'in' => 1, 'vstack' => 1 },
	'FPLDNLADDDB'	=> { 'in' => 1, 'fin' => 1, 'fout' => 1 },
	'FPLDNLMULDB'	=> { 'in' => 1, 'fin' => 1, 'fout' => 1 },
	'FPLDNLADDSN'	=> { 'in' => 1, 'fin' => 1, 'fout' => 1 },
	'FPLDNLMULSN'	=> { 'in' => 1, 'fin' => 1, 'fout' => 1 },
	'ENBS3'		=> { 'in' => 2, 'out' => 1, 'vstack' => 1 },
	'FPREM'		=> { 'fin' => 2, 'fout' => 1 },
	'FPDIVBY2'	=> { 'fin' => 1, 'fout' => 1 },
	'FPMULBY2'	=> { 'fin' => 1, 'fout' => 1 },
	'FPSQRT'	=> { 'fin' => 1, 'fout' => 1 },
	'FPRZ'		=> { },
	'FPR32TOR64'	=> { 'fin' => 1, 'fout' => 1 },
	'FPR64TOR32'	=> { 'fin' => 1, 'fout' => 1 },
	'FPEXPDEC32'	=> { 'fin' => 1, 'fout' => 1 },
	'FPABS'		=> { 'fin' => 1, 'fout' => 1 },
	'MALLOC'	=> { 'in' => 1, 'out' => 1, 'vstack' => 1 },
	'MRELEASE'	=> { 'in' => 1, 'vstack' => 1 },
	'XABLE'		=> { 'vstack' => 1 },
	'XIN'		=> { 'in' => 3, 'vstack' => 1 },
	'XEND'		=> { 'vstack' => 1 },
	'NULL'		=> { 'out' => 1,
			'generator' => \&gen_null },
	'PROC_ALLOC'	=> { 'in' => 2, 'out' => 1, 'vstack' => 1 },
	'PROC_PARAM'	=> { 'in' => 3, 'vstack' => 1 },
	'PROC_MT_COPY'	=> { 'in' => 3, 'vstack' => 1 },
	'PROC_MT_MOVE'	=> { 'in' => 3, 'vstack' => 1 },
	'PROC_START'	=> { 'in' => 3, 'vstack' => 1 },
	'PROC_END'	=> { 'in' => 1, 'vstack' => 1 },
	'GETAFF'	=> { 'out' => 1, 'vstack' => 1 },
	'SETAFF'	=> { 'in' => 1, 'vstack' => 1 },
	'GETPAS'	=> { 'out' => 1, 'vstack' => 1 },
	'MT_ALLOC'	=> { 'in' => 2, 'out' => 1, 'vstack' => 1 },
	'MT_RELEASE'	=> { 'in' => 1, 'vstack' => 1 },
	'MT_CLONE'	=> { 'in' => 1, 'out' => 1, 'vstack' => 1 },
	'MT_IN'		=> { 'in' => 2, 'vstack' => 1 },
	'MT_OUT'	=> { 'in' => 2, 'vstack' => 1 },
	'MT_XCHG'	=> { 'in' => 2, 'vstack' => 1 },
	'MT_LOCK'	=> { 'in' => 2, 'vstack' => 1 },
	'MT_UNLOCK'	=> { 'in' => 2, 'vstack' => 1 },
	'MT_ENROLL'	=> { 'in' => 2, 'vstack' => 1 },
	'MT_RESIGN'	=> { 'in' => 2, 'vstack' => 1 },
	'MT_SYNC'	=> { 'in' => 1, 'vstack' => 1 },
	'MT_XIN'	=> { 'in' => 2, 'vstack' => 1 },
	'MT_XOUT'	=> { 'in' => 2, 'vstack' => 1 },
	'MT_XXCHG'	=> { 'in' => 2, 'vstack' => 1 },
	'MT_DCLONE'	=> { 'in' => 3, 'out' => 1, 'vstack' => 1 },
	'MT_BIND'	=> { 'in' => 3, 'out' => 1, 'vstack' => 1 },
	'EXT_MT_IN'	=> { 'in' => 2, 'vstack' => 1 },
	'EXT_MT_OUT'	=> { 'in' => 2, 'vstack' => 1 },
	'MT_RESIZE'	=> { 'in' => 3, 'out' => 1, 'vstack' => 1 },
	'LEND'		=> { 'in' => 1,
		'generator' => \&gen_lend },
	'LEND3'		=> { 'in' => 1 },
	'LENDB'		=> { 'in' => 1 }
};


sub new ($$) {
	my ($class) = @_;
	my $self = bless {}, $class;
	$self->{'constants'}	= {};
	$self->{'globals'}	= {};
	$self->{'source_files'}	= {};
	$self->{'source_file'}	= undef;
	$self->{'source_line'} 	= 0;
	return $self;
}

sub foreach_label ($$@) {
	my ($labels, $func, @param) = @_;
	my @labels = keys (%$labels);
	foreach my $label (@labels) {
		&$func ($labels, $labels->{$label}, @param);
	}
}

sub foreach_inst ($$$@) {
	my ($labels, $label, $func, @param) = @_;
	my $inst = $label->{'inst'};
	foreach my $inst (@$inst) {
		&$func ($labels, $label, $inst, @param);
	}
}

sub resolve_inst_label ($$$$) {
	my ($labels, $label, $inst, $fn) = @_;
	
	return if $inst->{'name'} =~ /^\..*BYTES$/;
	
	my $arg = $inst->{'arg'};
	foreach my $arg (ref ($arg) =~ /^ARRAY/ ? @$arg : $arg) {
		if ($arg =~ /^L([0-9_\.]+)$/) {
			my $num	= $1;
			my $n	= 'L' . $fn . '.' . $num;
			if (!exists ($labels->{$n})) {
				die "Undefined label $n";
			} else {
				if ($arg eq $inst->{'arg'}) {
					$inst->{'arg'} = $labels->{$n};
				} else {
					$arg = $labels->{$n};
				}
				$labels->{$n}->{'refs'}++;
			}
			$inst->{'label_arg'} = 1;
		}
	}
}

sub resolve_labels ($$$) {
	my ($labels, $label, $fn) = @_;
	foreach_inst ($labels, $label, \&resolve_inst_label, $fn);
}

sub resolve_inst_globals ($$$$$) {
	my ($labels, $label, $inst, $globals, $ffi) = @_;
	if ($inst->{'label_arg'}) {
		my $arg = $inst->{'arg'};
		if ((ref ($arg) =~ /^HASH/) && $arg->{'stub'}) {
			my $n = $arg->{'stub'};
			if (exists ($globals->{$n})) {
				$inst->{'arg'} = $globals->{$n};
				$globals->{$n}->{'refs'}++;
			} elsif (exists ($ffi->{$n})) {
				$inst->{'arg'} = $ffi->{$n};
				$ffi->{$n}->{'refs'}++;
			} else {
				#die "Undefined global reference $n";
			}
		}
	}
}

sub resolve_globals ($$$$) {
	my ($labels, $label, $globals, $ffi) = @_;
	foreach_inst ($labels, $label, \&resolve_inst_globals, $globals, $ffi);
}

sub build_data_blocks ($$) {
	my ($labels, $label) = @_;
	my ($data, $inst) = (undef, 0);
	foreach my $op (@{$label->{'inst'}}) {
		my $name = $op->{'name'};
		if ($name =~ /^[^\.]/) {
			$inst++;
		} elsif ($name eq '.DATABYTES') {
			$data .= $op->{'arg'};
			$op->{'bytes'}	= [ split (//, $op->{'arg'}) ];
			$op->{'length'}	= length ($op->{'arg'});
		}
	}
	if (!$inst && $data) {
		$label->{'data'} = $data;
		if ($label->{'prev'}) {
			$label->{'prev'}->{'next'} = $label->{'next'};
		}
		if ($label->{'next'}) {
			$label->{'next'}->{'prev'} = $label->{'prev'};
		}
		delete ($label->{'prev'});
		delete ($label->{'next'});
	}
}

sub add_data_lengths ($$) {
	my ($labels, $label) = @_;
	if ($label->{'data'}) {
		$label->{'length'} = length ($label->{'data'});
	}
}

sub new_sub_label ($$$$) {
	my ($labels, $label, $current, $sub_idx) = @_;
	my $name		= sprintf ('%s_%d', $label->{'name'}, ($$sub_idx)++);
	my $new 		= {
		'name' => $name, 
		'prev' => $current,
		'next' => $current->{'next'},
		'inst' => undef
	};
	$current->{'next'}	= $new;
	if ($new->{'next'}) {
		$new->{'next'}->{'prev'} = $new;
	}
	$labels->{$name}	= $new;
	return $new;
}

sub isolate_branches ($$) {
	my ($labels, $label) = @_;
	
	return if $label->{'data'};

	my @inst	= @{$label->{'inst'}};
	my $sub_idx	= 0;
	my $current	= $label;
	my $cinst	= [];
	for (my $i = 0; $i < @inst; ++$i) {
		my $inst = $inst[$i];
		if ($inst->{'name'} =~ /^(J|CJ|LEND|CALL)$/i && $inst->{'label_arg'}) {
			if (@$cinst > 0) {
				$current->{'inst'}	= $cinst;
				$current		= new_sub_label (
					$labels, $label, $current, \$sub_idx
				);
				$cinst			= [];
			}
			$current->{'inst'}		= [ $inst ];
			$current 			= new_sub_label (
				$labels, $label, $current, \$sub_idx
			) if $i < (@inst - 1);
		} else {
			push (@$cinst, $inst);
		}
	}
	if (@$cinst > 0) {
		$current->{'inst'} = $cinst;
	}
}

sub tag_and_index_code_blocks ($) {
	my ($procs) = @_;
	foreach my $proc (@$procs) {
		my @labels	= ($proc);
		my $label	= $proc->{'next'};
		my $idx		= 0;
		$proc->{'proc'}	= $proc;
		$proc->{'idx'}	= $idx++;
		while ($label && !$label->{'symbol'}) {
			$label->{'proc'}	= $proc;
			$label->{'idx'}		= $idx++;
			push (@labels, $label);
			$label = $label->{'next'};
		}
		$proc->{'labels'} = \@labels;
	}
}

sub separate_code_blocks ($) {
	my ($procs) = @_;
	foreach my $proc (@$procs) {
		my $labels	= $proc->{'labels'};
		my $first	= $proc;
		my $last	= $labels->[-1];

		if ($first->{'prev'}) {
			delete ($first->{'prev'}->{'next'});
		}
		delete ($first->{'prev'});

		if ($last->{'next'}) {
			delete ($last->{'next'}->{'prev'});
		}
		delete ($last->{'next'});
	}
}

sub instruction_proc_dependencies ($$$$) {
	my (undef, $label, $inst, $depends) = @_;
	if ($inst->{'label_arg'}) {
		my $arg = $inst->{'arg'};
		foreach my $arg (ref ($arg) =~ /^ARRAY/ ? @$arg : $arg) {
			next if !ref ($arg);
			if ($label->{'proc'} ne $arg->{'proc'}) {
				$depends->{$arg} = $arg;
			}
		}
	}
}

sub expand_etc_ops ($) {
	my ($etc) = @_;
	my %IGNORE_SPECIAL = (
		'CONTRJOIN'	=> 1,
		'CONTRSPLIT'	=> 1,
		'FPPOP'		=> 1
	);
	my ($labn, $labo) = (0, 0);
	
	for (my $i = 0; $i < @$etc; ++$i) {
		my $op		= $etc->[$i];
		my $name	= $op->{'name'};
		my $arg		= $op->{'arg'};
		if ($name =~ /^\.(SET|SECTION)LAB$/) {
			$labn = $arg;
			$labo = 0;
		} elsif ($name eq '.LABEL') {
			if (ref ($arg) =~ /^ARRAY/) {
				my $l1 = $arg->[0];
				my $l2 = $arg->[1];
				if ($l2->{'arg'} >= 0) {
					$l1->{'arg'}	= [ $l1->{'arg'}, 'L' . $l2->{'arg'} ];
					$etc->[$i]	= $l1;
				} else {
					$l1->{'arg'} 	= [ $l1->{'arg'}, 'LDPI' ];
					splice (@$etc, $i, 1, 
						$l1,
						{ 'name' => 'LDPI' }
					);
				}
			} else {
				$etc->[$i] = $arg;
			}
		} elsif ($name eq '.SPECIAL') {
			my $name	= $arg->{'name'};

			if ($name eq 'NOTPROCESS') {
				$op = { 
					'name'	=> 'LDC',
					'arg'	=> 0
				};
			} elsif ($name eq 'STARTTABLE') {
				my (@arg, $done, @table);
				for (my $j = ($i+1); !$done && $j < @$etc; ++$j) {
					my $op = $etc->[$j];
					if ($op->{'name'} eq '.LABEL') {
						my $op = $op->{'arg'};
						if ($op->{'name'} eq 'J') {
							push (@arg, $op->{'arg'});
							push (@table, $op);
							next;
						}
					}
					$done = 1;
				}
				my $size_op		= {
					'name'		=> 'LDC',
					'arg'		=> 0
				};
				$op->{'name'}		= 'TABLE';
				$op->{'arg'}		= \@arg;
				$op->{'label_arg'}	= 1;
				$op->{'table'}		= \@table;
				$op->{'size_op'}	= $size_op;
				my $mlab = $labn + (++$labo / 10.0);
				my $jlab = $labn + (++$labo / 10.0);
				splice (@$etc, $i, 1,
					{},
					$size_op,
					{ 'name' => 'PROD'	},
					{ 'name' => 'LDC', 'arg' => [ "L$jlab", "L$mlab" ] },
					{ 'name' => 'LDPI'	},
					{ 'name' => '.SETLAB', 'arg' => $mlab		},
					{ 'name' => 'BSUB'	},
					{ 'name' => 'GCALL'	},
					{ 'name' => '.SETLAB', 'arg' => $jlab		},
					$op
				);
			} elsif (!exists ($IGNORE_SPECIAL{$name})) {
				$op = $arg;
			}
			
			$etc->[$i] = $op;
		} elsif ($name =~ /^\.(LEND.?)$/) {
			my $name	= $1;
			my @arg		= @$arg;
			my $start	= ($arg[2] =~ /^L(\d+)$/)[0];
			my $end		= ($arg[1] =~ /^L(\d+)$/)[0];
			splice (@$etc, $i, 1, 
				$arg[0],
				{ 'name' => $name, 'arg' => "L$start"			},
				{ 'name' => '.SETLAB', 'arg' => $end			}
			);
		} elsif ($name =~ /^\.SL([RL])IMM$/) {
			$op->{'name'} = "SH$1";
		}
	}
}

sub preprocess_etc ($$$) {
	my ($self, $file, $etc) = @_;
	my ($current, %labels, @procs);
	my $globals	= $self->{'globals'};
	
	my $fn		= 0;
	my $align	= 0;
	my $filename	= undef;
	my $line	= undef;

	# Initial operation translation
	expand_etc_ops ($etc);

	# Build ETC stream for each label
	# Identify PROCs and global symbols
	# Carry alignment
	# Carry file names and line numbers
	foreach my $op (@$etc) {
		my $name	= $op->{'name'};
		my $arg		= $op->{'arg'};

		if ($name eq '.ALIGN') {
			$align	= $arg;
		} elsif ($name =~ /^\.(SET|SECTION)LAB$/) {
			my $label = 'L' . $fn . '.' . $arg;
			my @inst;

			die "Label collision $label" 
				if exists ($labels{$label});
			
			if ($filename) {
				push (@inst, { 
					'name'	=> '.FILENAME',
					'arg'	=> $filename
				});
			}
			if (defined ($line)) {
				push (@inst, {
					'name'	=> '.LINE',
					'arg'	=> $line
				});
			}
			if ($align) {
				push (@inst, {
					'name'	=> '.ALIGN',
					'arg'	=> $align
				});
			}

			my $new = { 
				'name'		=> $label, 
				'prev'		=> $current, 
				'inst'		=> \@inst,
				'align'		=> $align,
				'source'	=> $etc
			};

			$current->{'next'} 	= $new;
			$current 		= $new;
			$labels{$label}		= $new;

			$align			= 0;
		} elsif ($name eq '.FILENAME') {
			$filename		= $arg;
		} elsif ($name eq '.LINE') {
			$line			= $arg;
		} elsif ($name eq '.PROC') {
			$current->{'symbol'}	= $arg;
			push (@procs, $current);
		} elsif ($name eq '.STUBNAME') {
			$current->{'stub'}	= $arg;
			$current->{'symbol'}	= $arg;
			#if ($arg =~ /^(C|BX?)\./) {
			#	$ffi{$arg} = $current
			#		if !exists ($ffi{$arg});
			#}
		} elsif ($name eq '.GLOBAL') {
			if (exists ($globals->{$arg})) {
				my $current 	= $globals->{$arg};
				my $c_file	= $current->{'loci'}->{'file'};
				my $c_fn	= $current->{'loci'}->{'filename'};
				my $c_ln	= $current->{'loci'}->{'line'};
				print STDERR 
					"Warning: multiple definitions of global name '$arg'\n",
					"\tOld symbol is from $c_fn($c_file), line $c_ln.";
					"\tNew symbol is from $filename($file), line $line.";
			}
			$globals->{$arg}	= $current;
			$current->{'loci'}	= {
				'file'		=> $file,
				'filename'	=> $filename,
				'line'		=> $line
			};
		} elsif ($name eq '.GLOBALEND') {
			$globals->{$arg}->{'end'} = $current;
		}
		
		push (@{$current->{'inst'}}, $op)
			if $current; 
	}

	$self->{'file'}		= $file;
	$self->{'filename'}	= $filename;
	$self->{'labels'}	= \%labels;
	$self->{'procs'}	= \@procs;

	foreach_label (\%labels, \&resolve_labels, 0);
	foreach_label (\%labels, \&resolve_globals, $globals, {});
	foreach_label (\%labels, \&build_data_blocks);
	foreach_label (\%labels, \&add_data_lengths);
	foreach_label (\%labels, \&isolate_branches);
	tag_and_index_code_blocks (\@procs);
	separate_code_blocks (\@procs);
}

sub define_registers ($$) {
	my ($self, $labels) = @_;
	my ($reg_n, $freg_n, $wptr_n) = (0, 0, 0);
	my $wptr = sprintf ('wptr_%d', $wptr_n++);
	my (@stack, @fstack);

	foreach my $label (@$labels) {
		#print $label->{'name'}, " ", join (', ', @stack, @fstack), " ($wptr)\n";
		
		$label->{'in'} = [ @stack ];
		$label->{'fin'} = [ @fstack ];
		$label->{'wptr'} = $wptr;

		foreach my $inst (@{$label->{'inst'}}) {
			my $name = $inst->{'name'};
			next if $name =~ /^\./;
			my (@in, @out, @fin, @fout);
			my $data	= $GRAPH->{$name};
			for (my $i = 0; $i < $data->{'in'}; ++$i) {
				my $reg = shift (@stack);
				push (@in, $reg) if $reg;
			}
			my $out = $data->{'out'};
			if ($name eq 'CJ') {
				$out = @in - ($data->{'in'} - $out);
			}
			for (my $i = 0; $i < $out; ++$i) {
				my $reg = sprintf ('reg_%d', $reg_n++);
				unshift (@out, $reg);
				unshift (@stack, $reg);
			}
			for (my $i = 0; $i < $data->{'fin'}; ++$i) {
				my $reg = shift (@fstack) || 'null';
				unshift (@in, $reg);
			}
			for (my $i = 0; $i < $data->{'fout'}; ++$i) {
				my $reg = sprintf ('freg_%d', $freg_n++);
				unshift (@out, $reg);
				unshift (@stack, $reg);
			}
			$inst->{'in'} = \@in if @in;
			$inst->{'out'} = \@out if @out;
			$inst->{'fin'} = \@fin if @fin;
			$inst->{'fout'} = \@fout if @fout;
			$inst->{'wptr'} = $wptr;
			if ($data->{'wptr'}) {
				$wptr = sprintf ('wptr_%d', $wptr_n++);
				$inst->{'_wptr'} = $wptr;
			}
			if (0) {
				print "\t";
				print join (', ', @in, @fin), " => " if @in || @fin;
				print $name;
				if ($inst->{'label_arg'}) {
					print ' ', $inst->{'arg'}->{'name'};
				}
				print " => ", join (', ', @out, @fout) if @out || @fout;
				if ($data->{'wptr'}) {
					print " (", $inst->{'wptr'}, ' => ', $inst->{'_wptr'}, ")";
				}
				print "\n";
			}
			@stack = @stack[0..2] if @stack > 3;
			@fstack = @fstack[0..2] if @fstack > 3;
		}
		
		$label->{'out'} = [ @stack ];
		$label->{'fout'} = [ @fstack ];
		$label->{'_wptr'} = $wptr;
	}
}	

sub build_phi_nodes ($$) {
	my ($self, $labels) = @_;

	foreach my $label (@$labels) {
		my $lname = $label->{'name'};

		foreach my $inst (@{$label->{'inst'}}) {
			next if $inst->{'name'} ne 'CJ';
			my $tlabel = $inst->{'arg'};
			$tlabel->{'phi'} = {} if !$tlabel->{'phi'};
			$tlabel->{'phi'}->{$lname} = [ $label->{'wptr'}, @{$inst->{'in'}} ];
		}
	}
}


sub output_regs (@) {
	my (@regs) = @_;
	return if !@regs;
	my @out;
	foreach my $regs (@regs) {
		foreach my $reg (@$regs) {
			push (@out, '%' . $reg);
		}
	}
	return join (', ', @out);
}

sub int_type {
	my $self = shift;
	return 'i32'; # FIXME:
}

sub index_type {
	my $self = shift;
	if ($self->int_type eq 'i64') {
		return 'i64';
	} else {
		return 'i32';
	}
}

sub float_type {
	my $self = shift;
	return 'double';
}

sub workspace_type {
	my $self = shift;
	return $self->int_type . '*';
}

sub reset_tmp ($) {
	my $self = shift;
	$self->{'tmp_n'} = 0;
}

sub tmp_label ($) {
	my $self = shift;
	my $n = $self->{'tmp_n'}++;
	return "tmp_$n";
}

sub tmp_reg ($) {
	my $self = shift;
	my $n = $self->{'tmp_n'}++;
	return "tmp_$n";
}

sub new_constant ($$$) {
	my ($self, $name, $value) = @_;
	die "Trying to create duplicate constant" if exists ($self->{'constants'}->{$name});
	$self->{'constants'}->{$name} = $value;
}

sub new_generated_constant ($$) {
	my ($self, $value) = @_;
	my $name = sprintf ('C_%d', $self->{'constant_n'}++);
	$self->new_constant ($name, $value);
	return $name;
}

sub source_file {
	my ($self, $file) = @_;
	if (defined ($file)) {
		$self->{'source_file'} = $self->{'source_files'}->{$file};
		if (!$self->{'source_file'}) {
			my $constant = $self->new_generated_constant (
				{ 'str' => $file }
			);
			$self->{'source_files'}->{$file} = $constant;
			$self->{'source_file'} = $constant;
		}
	}
	return $self->{'source_file'};
}

sub source_line {
	my ($self, $line) = @_;
	if (defined ($line)) {
		$self->{'source_line'} = $line;
	}
	return $self->{'source_line'};
}

sub int_constant ($$) {
	my ($self, $int) = @_;
	my $int_type = $self->int_type;
	return sprintf ('bitcast %s %d to %s', $int_type, $int, $int_type)
}

sub single_assignment ($$$$) {
	my ($self, $type, $src, $dst) = @_;
	return sprintf ('%%%s = bitcast %s %%%s to %s', $dst, $type, $src, $type);
}

sub global_ptr_value ($$$) {
	my ($self, $type, $global) = @_;
	my $tmp_reg = $self->tmp_reg ();
	return ($tmp_reg, 
		sprintf ('%%%s = load %s* @%s', $tmp_reg, $type, $global)
	);
}

sub _gen_error ($$$$$) {
	my ($self, $proc, $label, $inst, $type) = @_;
	my ($source_reg, $source_asm) = $self->global_ptr_value ('i8*', $self->source_file);
	return (
		$source_asm,
		sprintf ('call void @etc_error_%s (%s %%%s, i8* %%%s, %s %s)',
			$type,
			$self->workspace_type, $inst->{'wptr'},
			$source_reg,
			$self->int_type, $self->source_line
		)
	);
}

sub gen_j ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	return 'br label %' . $inst->{'arg'}->{'name'};
}

sub gen_cj ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	my $tmp_reg = $self->tmp_reg ();
	return (
		sprintf ('%%%s = icmp eq %s %%%s, %d',
			$tmp_reg,
			$self->int_type, $inst->{'in'}->[0],
			0
		),
		sprintf ('br i1 %%%s, label %%%s, label %%%s',
			$tmp_reg,
			$inst->{'arg'}->{'name'},
			$label->{'next'}->{'name'}
		)
	);
}

sub gen_call ($$$$) { 
	my ($self, $proc, $label, $inst) = @_;
	my @asm;
	
	my $in = $inst->{'in'};
	if (exists ($inst->{'fin'})) {
		push (@asm, "; WARNING: point stack is not empty at point of call");
	}

	my $new_wptr = $self->tmp_reg ();
	push (@asm, sprintf ('%%%s = getelementptr %s %%%s, %s %d',
		$new_wptr,
		$self->workspace_type, $inst->{'wptr'},
		$self->index_type, -4
	));

	for (my $i = 0; $i < @$in; ++$i) {
		my $tmp_reg = $self->tmp_reg ();
		push (@asm, sprintf ('%%%s = getelementptr %s %%%s, %s %d',
			$tmp_reg,
			$self->workspace_type, $new_wptr,
			$self->index_type, ($i + 1)
		));
		push (@asm, sprintf ('store %s %%%s, %s %%%s',
			$self->int_type, $in->[$i],
			$self->workspace_type, $tmp_reg
		));
	}

	# FIXME: do call
	#push (@asm, 'call...');

	return @asm;
}	

sub gen_ajw ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	return sprintf ('%%%s = getelementptr %s %%%s, %s %d',
		$inst->{'_wptr'},
		$self->workspace_type, $inst->{'wptr'},
		$self->index_type, $inst->{'arg'}
	);
}

sub gen_ldc ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	return sprintf ('%%%s = %s',
		$inst->{'out'}->[0],
		$self->int_constant ($inst->{'arg'})
	);
}

sub gen_mint ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	my $type = $self->int_type;
	my $bits = ($type =~ /i(\d+)/)[0];
	my $mint = -(1 << ($bits - 1));
	return $self->gen_ldc ($proc, $label, {
		'out' => $inst->{'out'},
		'arg' => $mint
	});
}

sub gen_null ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	return $self->gen_ldc ($proc, $label, {
		'out' => $inst->{'out'},
		'arg' => 0
	});
}

sub _gen_ldlp ($$) {
	my ($self, $inst) = @_;
	my ($reg, @asm);
	if ($inst->{'arg'} != 0) {
		$reg = $self->tmp_reg ();
		push (@asm, 
			sprintf ('%%%s = getelementptr %s %%%s, %s %d',
				$reg, 
				$self->workspace_type, $inst->{'wptr'},
				$self->index_type, $inst->{'arg'}
		));
	} else {
		$reg = $inst->{'wptr'};
	}
	return ($reg, @asm);
}

sub gen_ldlp ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	my ($tmp_reg, @asm) = $self->_gen_ldlp ($inst);
	my $conv = sprintf ('%%%s = ptrtoint %s %%%s to %s',
		$inst->{'out'}->[0],
		$self->workspace_type,
		$tmp_reg,
		$self->int_type
	);
	return (@asm, $conv);
}

sub gen_ldl ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	my ($tmp_reg, @asm) = $self->_gen_ldlp ($inst);
	my $load = sprintf ('%%%s = load %s %%%s',
		$inst->{'out'}->[0],
		$self->workspace_type, $tmp_reg
	);
	return (@asm, $load);
}	

sub gen_stl ($$$$) { 
	my ($self, $proc, $label, $inst) = @_;
	my ($tmp_reg, @asm) = $self->_gen_ldlp ($inst);
	my $store = sprintf ('store %s %%%s, %s %%%s',
		$self->int_type, $inst->{'in'}->[0],
		$self->workspace_type, $tmp_reg
	);
	return (@asm, $store);
}

sub _gen_ldnlp ($$) {
	my ($self, $inst) = @_;
	my ($reg, @asm);
	my $ptr_reg = $self->tmp_reg ();
	push (@asm,
		sprintf ('%%%s = inttoptr %s %%%s to %s',
			$ptr_reg, 
			$self->int_type, $inst->{'in'}->[0], 
			$self->int_type . '*'
		)
	);
	if ($inst->{'arg'} != 0) {
		$reg = $self->tmp_reg ();
		push (@asm, 
			sprintf ('%%%s = getelementptr %s %%%s, %s %d',
				$reg, 
				$self->int_type . '*', $ptr_reg,
				$self->index_type, $inst->{'arg'}
		));
	} else {
		$reg = $ptr_reg;
	}
	return ($reg, @asm);
}

sub gen_ldnl ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	my ($tmp_reg, @asm) = $self->_gen_ldnlp ($inst);
	my $load = sprintf ('%%%s = load %s %%%s',
		$inst->{'out'}->[0],
		$self->workspace_type, $tmp_reg
	);
	return (@asm, $load);
}	

sub gen_stnl ($$$$) { 
	my ($self, $proc, $label, $inst) = @_;
	my ($tmp_reg, @asm) = $self->_gen_ldnlp ($inst);
	my $store = sprintf ('store %s %%%s, %s %%%s',
		$self->int_type, $inst->{'in'}->[1],
		$self->workspace_type, $tmp_reg
	);
	return (@asm, $store);
}

sub gen_dup ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	my @asm;
	my $in = $inst->{'in'}->[0];
	foreach my $reg (@{$inst->{'out'}}) {
		push (@asm, $self->single_assignment (
			$self->int_type, $inst->{'in'}->[0], $reg
		)); 
	}
	return @asm;
}

sub _gen_checked_arithmetic ($$$$$) {
	my ($self, $proc, $label, $inst, $func) = @_;
	my @asm;
	my $in		= $inst->{'in'};
	my $res 	= $self->tmp_reg ();
	my $overflow 	= $self->tmp_reg ();
	my $tmp		= $self->tmp_label ();
	my $error_lab	= $tmp . '_overflow_error';
	my $ok_lab	= $tmp . '_ok';

	push (@asm, sprintf ('%%%s = call {%s, i1} %s (%s %%%s, %s %%%s)',
		$res, 
		$self->int_type,
		$func,
		$self->int_type, $in->[0],
		$self->int_type, $in->[1]
	));
	push (@asm, sprintf ('%%%s = extractvalue {%s, i1} %%%s, 0',
		$inst->{'out'}->[0],
		$self->int_type,
		$res
	));
	push (@asm, sprintf ('%%%s = extractvalue {%s, i1} %%%s, 1',
		$overflow,
		$self->int_type,
		$res
	));
	push (@asm, sprintf ('br i1 %%%s, label %%%s, label %%%s',
		$overflow,
		$error_lab,
		$ok_lab
	));
	push (@asm, $error_lab . ':');
	push (@asm, $self->_gen_error ($proc, $label, $inst, 'overflow'));
	push (@asm, sprintf ('br label %%%s', $ok_lab));
	push (@asm, $ok_lab . ':');

	return @asm;
}

sub gen_add ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	return $self->_gen_checked_arithmetic (
		$proc, $label, $inst,
		'@llvm.sadd.with.overflow.' . $self->int_type
	);
}

sub gen_adc ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	my $tmp_reg = $self->tmp_reg ();
	my @ldc = $self->gen_ldc ($proc, $label, { 
		'arg' 	=> $inst->{'arg'},
		'out' 	=> [ $tmp_reg ]
	});
	my @add = $self->gen_add ($proc, $label, {
		'wptr'	=> $inst->{'wptr'},
		'in' 	=> [ @{$inst->{'in'}}, $tmp_reg ],
		'out'	=> $inst->{'out'}
	});
	return (@ldc, @add);
}

sub gen_sub ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	return $self->_gen_checked_arithmetic (
		$proc, $label, $inst,
		'@llvm.ssub.with.overflow.' . $self->int_type
	);
}

sub gen_mul ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	return $self->_gen_checked_arithmetic (
		$proc, $label, $inst,
		'@llvm.smul.with.overflow.' . $self->int_type
	);
}

sub gen_sum ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	return sprintf ('%%%s = add %s %%%s, %%%s',
		$inst->{'out'}->[0],
		$self->int_type,
		$inst->{'in'}->[0], $inst->{'in'}->[1]
	);
}	

sub gen_diff ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	return sprintf ('%%%s = sub %s %%%s, %%%s',
		$inst->{'out'}->[0],
		$self->int_type,
		$inst->{'in'}->[0], $inst->{'in'}->[1]
	);
}	

sub gen_prod ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	return sprintf ('%%%s = mul %s %%%s, %%%s',
		$inst->{'out'}->[0],
		$self->int_type,
		$inst->{'in'}->[0], $inst->{'in'}->[1]
	);
}	

sub gen_rev ($$$$) { 
	my ($self, $proc, $label, $inst) = @_;
	return (
		sprintf ('%%%s = %s %%%s to %s', 
			$inst->{'out'}->[0],
			$self->int_type,
			$inst->{'in'}->[1],
			$self->int_type
		),
		sprintf ('%%%s = %%%s', $inst->{'out'}->[1], $inst->{'in'}->[0])
	);
}

sub gen_eqc ($$$$) { 
	my ($self, $proc, $label, $inst) = @_;
	my $tmp_reg = $self->tmp_reg ();
	return (
		sprintf ('%%%s = icmp eq %s %%%s, %d', 
			$tmp_reg, 
			$self->int_type,
			$inst->{'in'}->[0], $inst->{'arg'}
		),
		sprintf ('%%%s = zext i1 %%%s to %s', 
			$inst->{'out'}->[0], 
			$tmp_reg,
			$self->int_type
		)
	);
}

sub gen_gt ($$$$) { 
	my ($self, $proc, $label, $inst) = @_;
	my $tmp_reg = $self->tmp_reg ();
	return (
		sprintf ('%%%s = icmp sgt %s %%%s, %%%s', 
			$tmp_reg,
			$self->int_type,
			$inst->{'in'}->[0], $inst->{'in'}->[1]
		),
		sprintf ('%%%s = zext i1 %%%s to %s', 
			$inst->{'out'}->[0], 
			$tmp_reg,
			$self->int_type
		)
	);
}


sub _gen_bitop ($$$@) { 
	my ($self, $inst, $op, @in) = @_;
	return sprintf ('%%%s = %s %s %%%s, %d',
		$inst->{'out'}->[0],
		$op,
		$self->int_type, 
		@in
	);
}

sub gen_not ($$$$) { 
	my ($self, $proc, $label, $inst) = @_;
	return $self->_gen_bitop ($inst, 'xor', @{$inst->{'in'}}, -1);
}

sub gen_xor ($$$$) { 
	my ($self, $proc, $label, $inst) = @_;
	return $self->_gen_bitop ($inst, 'xor', @{$inst->{'in'}});
}

sub gen_or ($$$$) { 
	my ($self, $proc, $label, $inst) = @_;
	return $self->_gen_bitop ($inst, 'xor', @{$inst->{'in'}});
}

sub gen_and ($$$$) { 
	my ($self, $proc, $label, $inst) = @_;
	return $self->_gen_bitop ($inst, 'and', @{$inst->{'in'}});
}

sub gen_shr ($$$$) { 
	my ($self, $proc, $label, $inst) = @_;
	return $self->_gen_bitop ($inst, 'lshr', @{$inst->{'in'}});
}

sub gen_shl ($$$$) { 
	my ($self, $proc, $label, $inst) = @_;
	return $self->_gen_bitop ($inst, 'shl', @{$inst->{'in'}});
}

sub gen_nop ($$$$) { 
	my ($self, $proc, $label, $inst) = @_;
	return ();
}

sub gen_ret ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	return 'ret void';
}

sub gen_csub0 ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	my $error 	= $self->tmp_reg ();
	my $tmp		= $self->tmp_label ();
	my $error_lab	= $tmp . '_bounds_error';
	my $ok_lab	= $tmp . '_ok';
	my @asm;
	push (@asm, $self->single_assignment (
		$self->int_type, $inst->{'in'}->[1], $inst->{'out'}->[0]
	));
	push (@asm, sprintf ('%%%s = icmp uge %s %%%s, %%%s',
		$error, $self->int_type, $inst->{'in'}->[1], $inst->{'in'}->[0]
	));
	push (@asm, sprintf ('br i1 %%%s, label %%%s, label %%%s',
		$error, $error_lab, $ok_lab
	));
	push (@asm, $error_lab . ':');
	push (@asm, $self->_gen_error ($proc, $label, $inst, 'bounds'));
	push (@asm, sprintf ('br label %%%s', $ok_lab));
	push (@asm, $ok_lab . ':');

	return @asm;
}

sub gen_lend ($$$$) {
	my ($self, $proc, $label, $inst) = @_;
	my $block_ptr		= $self->tmp_reg ();
	my $index_ptr		= $self->tmp_reg ();
	my $block_cnt		= $self->tmp_reg ();
	my $new_block_cnt	= $self->tmp_reg ();
	my $index_cnt		= $self->tmp_reg ();
	my $new_index_cnt	= $self->tmp_reg ();
	my $loop_cond		= $self->tmp_reg ();
	my $loop_lab		= $self->tmp_label ();
	my @asm;
	push (@asm, sprintf ('%%%s = inttoptr %s %%%s to %s',
		$index_ptr, $self->int_type, $inst->{'in'}->[0], $self->int_type . '*'
	));
	push (@asm, sprintf ('%%%s = getelementptr %s %%%s, %s %d',
		$block_ptr,
		$self->int_type . '*', $index_ptr,
		$self->index_type, 1
	));
	push (@asm, sprintf ('%%%s = load %s %%%s',
		$block_cnt,
		$self->int_type . '*', $block_ptr
	));
	push (@asm, sprintf ('%%%s = sub %s %%%s, %d',
		$new_block_cnt,
		$self->int_type, $block_cnt, 1
	));
	push (@asm, sprintf ('store %s %%%s, %s %%%s',
		$self->int_type, $new_block_cnt,
		$self->int_type . '*', $block_ptr
	));
	push (@asm, sprintf ('%%%s = icmp ugt %s %%%s, %d',
		$loop_cond,
		$self->int_type, $new_block_cnt, 0
	));
	push (@asm, sprintf ('br i1 %%%s, label %%%s, label %%%s',
		$loop_cond, $loop_lab, $label->{'next'}->{'name'}
	));
	push (@asm, $loop_lab . ':');
	push (@asm, sprintf ('%%%s = load %s %%%s',
		$index_cnt,
		$self->int_type . '*', $index_ptr
	));
	push (@asm, sprintf ('%%%s = add %s %%%s, %d',
		$new_index_cnt,
		$self->int_type, $index_cnt, 1
	));
	push (@asm, sprintf ('store %s %%%s, %s %%%s',
		$self->int_type, $new_index_cnt,
		$self->int_type . '*', $index_ptr
	));
	push (@asm, $self->gen_j ($proc, $label, $inst));

	return @asm;
}

sub format_lines (@) {
	my @lines = @_;
	my @asm;
	foreach my $line (@lines) {
		if ($line =~ /^[a-zA-Z0-9\$\._]+:/) {
			push (@asm, $line);
		} else {
			push (@asm, "\t" . $line);
		}
	}
	return @asm;
}

sub generate_proc ($$) {
	my ($self, $proc) = @_;
	my @asm;

	push (@asm, join ('', 
		'define void @O_', $proc->{'symbol'}, 
			'(i32 *%', $proc->{'labels'}->[0]->{'wptr'}, ') {'
	));
	foreach my $label (@{$proc->{'labels'}}) {
		my ($name, $insts) = ($label->{'name'}, $label->{'inst'});
		my $last_inst;
		push (@asm, 
			$label->{'name'} . ':'
		);
		if ($label->{'phi'}) {
			my $wptr	= $label->{'wptr'};
			my $in 		= $label->{'in'} || [];
			my $fin 	= $label->{'fin'} || [];
			my @vars 	= ( $wptr, @$in, @$fin );
			my %var_map 	= ( map { $_ => [] } @vars ); # build hash of arrays for each var
			my %type 	= ( $wptr => $self->workspace_type );
			foreach my $var (@$in) {
				$type{$var} = $self->int_type;
			}
			foreach my $var (@$fin) {
				$type{$var} = $self->float_type;
			}
			my $wptr_same = 1;
			foreach my $slabel (keys (%{$label->{'phi'}})) {
				my $svars = $label->{'phi'}->{$slabel};
				for (my $i = 0; $i < @vars; ++$i) {
					$wptr_same = $wptr_same && $vars[$i] eq $svars->[$i]
						if $i == 0;
					push (@{$var_map{$vars[$i]}},
						'[ %' . $svars->[$i] . ', %' . $slabel . ' ]'
					);
				}
			}
			shift @vars if $wptr_same;
			foreach my $var (@vars) {
				push (@asm, join ('', 
					"\t", '%', $var, 
					' = phi ', $type{$var}, ' ', join (' ', @{$var_map{$var}})
				));
			}
		}
		foreach my $inst (@$insts) {
			my $name 	= $inst->{'name'};
			
			if ($name =~ /^\./) {
				if ($name eq '.LINE') {
					$self->source_line ($inst->{'arg'});
				} elsif ($name eq '.FILENAME') {
					$self->source_file ($inst->{'arg'});
				}
				next;
			}
			
			my $line = "\t; $name";
			if (exists ($inst->{'arg'})) {
				$line .= " ";
				if (exists ($inst->{'label_arg'})) {
					$line .= $inst->{'arg'}->{'name'};
				} else {
					$line .= $inst->{'arg'};
				}
			}
			push (@asm, $line);
			
			my $data	= $GRAPH->{$name};
			my $in 		= $inst->{'in'} || [];
			my $fin 	= $inst->{'fin'} || [];
			my $out 	= $inst->{'out'} || [];
			my $fout 	= $inst->{'fout'} || [];
			
			if ($data->{'generator'}) {
				my @lines = &{$data->{'generator'}}($self, $proc, $label, $inst);
				push (@asm, format_lines (@lines));
			} elsif (@$out + @$fout == 1) {
				my $line = "\t";
				$line .= output_regs ($out, $fout);
				$line .= " = call void \@op_" . $name . " (%" . $inst->{'wptr'};
				$line .= ', ' . $inst->{'arg'} if exists ($inst->{'arg'});
				$line .= ', ' if (@$in + @$fin > 0);
				$line .= output_regs ($in, $fin);
				$line .= ')';
				push (@asm, $line);
			} else {
				my $line = "\t";
				$line .= '%', $inst->{'_wptr'}, ' = ' if $inst->{'_wptr'};
				$line .= "call void \@op_" . $name . " (%" . $inst->{'wptr'};
				$line .= ', ' . $inst->{'arg'} if exists ($inst->{'arg'});
				$line .= ', ' if (@$in + @$fin > 0);
				$line .= output_regs ($in, $fin, $out, $fout);
				$line .= ")";
				push (@asm, $line);
			}
			
			$last_inst = $inst;
		}
		if ($last_inst->{'name'} !~ /^(J|CJ|LEND|RET)$/) {
			my $next_label = $label->{'next'};
			push (@asm, format_lines (
				$self->gen_j ($proc, $label, {
					'wptr' 	=> $last_inst->{'wptr'},
					'arg'	=> $next_label
				})
			));
		}
	}
	push (@asm, '}');

	return @asm;
}

sub code_constants ($) {
	my $self = shift;
	my $constants = $self->{'constants'};
	my @asm;

	foreach my $name (sort (keys (%$constants))) {
		my $value = $constants->{$name};
		if (exists ($value->{'str'})) {
			my $str = $value->{'str'};
			my @chr = split (//, $str);
			foreach my $chr (@chr) {
				$chr = 'i8 ' . ord ($chr);
			}
			push (@chr, 'i8 0');
			push (@asm, "; \@$name = \"$str\"");
			push (@asm, sprintf ('@%s_value = internal constant [ %d x i8 ] [ %s ]',
				$name, scalar (@chr), join (', ', @chr)
			));
			push (@asm, sprintf ('@%s = internal constant i8* getelementptr ([ %d x i8 ]* @%s_value, i32 0, i32 0)',
				$name, scalar (@chr), $name
			));
		}
	}

	return @asm;
}

sub code_proc ($$) {
	my ($self, $proc) = @_;
	
	$self->reset_tmp ();

	$self->define_registers ($proc->{'labels'});
	$self->build_phi_nodes ($proc->{'labels'});
	
	my $comments = "; " . $proc->{'symbol'};
	return ($comments, $self->generate_proc ($proc));
}

sub intrinsics ($) {
	my $self = shift;
	my $int = $self->int_type;
	return (
		"declare { $int, i1 } \@llvm.sadd.with.overflow.$int ($int, $int)",
		"declare { $int, i1 } \@llvm.smul.with.overflow.$int ($int, $int)",
		"declare { $int, i1 } \@llvm.ssub.with.overflow.$int ($int, $int)"
	);
}

sub generate ($$) {
	my ($self, $text) = @_;
	my $verbose = $self->{'verbose'};
	my $file	= $text->{'file'};
	my $etc		= $text->{'etc'};

	$self->preprocess_etc ($file, $etc);

	my @header = $self->intrinsics;
	# for debugging
	push (@header, sprintf ('declare void @etc_error_bounds (%s, i8*, %s)',
		$self->workspace_type, $self->int_type
	));
	push (@header, sprintf ('declare void @etc_error_overflow (%s, i8*, %s)',
		$self->workspace_type, $self->int_type
	));

	my @proc_asm;
	foreach my $proc (@{$self->{'procs'}}) {
		push (@proc_asm, $self->code_proc ($proc));
	}
	
	my @const_asm 	= $self->code_constants ();
	
	my @ret 	= (@header, @const_asm, @proc_asm);
	foreach my $line (@ret) {
		print $line, "\n";
	}

	return \@ret;
}

1;
