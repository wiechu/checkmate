#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

#  Description: Checkmate the black king in two moves
#
#       Author: wiechu
#
#  Github Page: https://github.com/wiechu/checkmate

use constant WHITE => 1;
use constant BLACK => 0;

use constant KING   => 8;
use constant QUEEN  => 7;
use constant ROCK   => 6;
use constant BISHOP => 5;
use constant KNIGHT => 4;
use constant PAWN   => 3;

my @board;    # i know: global variables sucks

###############################################################################
#
# Subroutines
#

sub king {
    my ($square) = @_;
    my $col      = $square->{col};
    my $row      = $square->{row};
    my @moves;

    # TODO castling
    if ( my $m = can_move( $square, $col - 1, $row - 1 ) ) { push @moves, $m }
    if ( my $m = can_move( $square, $col - 1, $row ) )     { push @moves, $m }
    if ( my $m = can_move( $square, $col - 1, $row + 1 ) ) { push @moves, $m }
    if ( my $m = can_move( $square, $col,     $row - 1 ) ) { push @moves, $m }
    if ( my $m = can_move( $square, $col,     $row + 1 ) ) { push @moves, $m }
    if ( my $m = can_move( $square, $col + 1, $row - 1 ) ) { push @moves, $m }
    if ( my $m = can_move( $square, $col + 1, $row ) )     { push @moves, $m }
    if ( my $m = can_move( $square, $col + 1, $row + 1 ) ) { push @moves, $m }
    return @moves;
}

sub queen {
    my ($square) = @_;
    my @r        = rock($square);
    my @b        = bishop($square);
    my @moves    = ( @r, @b );

    return @moves;
}

sub rock {
    my ($square) = @_;
    my $col      = $square->{col};
    my $row      = $square->{row};
    my @moves;

    # up
    for my $i ( 1 .. 7 ) {
        last unless my $m = can_move( $square, $col, $row + $i );
        push @moves, $m;
        last if $m->{capture};
    }

    # down
    for my $i ( 1 .. 7 ) {
        last unless my $m = can_move( $square, $col, $row - $i );
        push @moves, $m;
        last if $m->{capture};
    }

    # left
    for my $i ( 1 .. 7 ) {
        last unless my $m = can_move( $square, $col - $i, $row );
        push @moves, $m;
        last if $m->{capture};
    }

    # right
    for my $i ( 1 .. 7 ) {
        last unless my $m = can_move( $square, $col + $i, $row );
        push @moves, $m;
        last if $m->{capture};
    }

    return @moves;
}

sub bishop {
    my ($square) = @_;
    my $col      = $square->{col};
    my $row      = $square->{row};
    my @moves;

    # up right
    for my $i ( 1 .. 7 ) {
        last unless my $m = can_move( $square, $col + $i, $row + $i );
        push @moves, $m;
        last if $m->{capture};
    }

    # up left
    for my $i ( 1 .. 7 ) {
        last unless my $m = can_move( $square, $col - $i, $row + $i );
        push @moves, $m;
        last if $m->{capture};
    }

    # down left
    for my $i ( 1 .. 7 ) {
        last unless my $m = can_move( $square, $col - $i, $row - $i );
        push @moves, $m;
        last if $m->{capture};
    }

    # down right
    for my $i ( 1 .. 7 ) {
        last unless my $m = can_move( $square, $col + $i, $row - $i );
        push @moves, $m;
        last if $m->{capture};
    }

    return @moves;
}

sub knight {
    my ($square) = @_;
    my $col      = $square->{col};
    my $row      = $square->{row};
    my @moves;

    if ( my $m = can_move( $square, $col - 2, $row - 1 ) ) { push @moves, $m }
    if ( my $m = can_move( $square, $col - 2, $row + 1 ) ) { push @moves, $m }
    if ( my $m = can_move( $square, $col - 1, $row - 2 ) ) { push @moves, $m }
    if ( my $m = can_move( $square, $col - 1, $row + 2 ) ) { push @moves, $m }
    if ( my $m = can_move( $square, $col + 1, $row - 2 ) ) { push @moves, $m }
    if ( my $m = can_move( $square, $col + 1, $row + 2 ) ) { push @moves, $m }
    if ( my $m = can_move( $square, $col + 2, $row - 1 ) ) { push @moves, $m }
    if ( my $m = can_move( $square, $col + 2, $row + 1 ) ) { push @moves, $m }
    return @moves;
}

sub pawn {
    my ($square) = @_;
    my $col      = $square->{col};
    my $row      = $square->{row};
    my @moves;

    # TODO pawn promotion
    if ( $square->{color} eq WHITE ) {

        # capture right
        if ( my $m = can_move( $square, $col + 1, $row + 1 ) ) {
            push @moves, $m if $m->{capture};
        }

        # capture left
        if ( my $m = can_move( $square, $col - 1, $row + 1 ) ) {
            push @moves, $m if $m->{capture};
        }

        # forward
        if ( my $m = can_move( $square, $col, $row + 1 ) ) {
            unless ( $m->{capture} ) {
                push @moves, $m;
                if ( 2 == $row ) {
                    if ( my $m = can_move( $square, $col, $row + 2 ) ) {
                        push @moves, $m;
                    }
                }
            }
        }
    } else {

        # capture right
        if ( my $m = can_move( $square, $col + 1, $row - 1 ) ) {
            push @moves, $m if $m->{capture};
        }

        # capture left
        if ( my $m = can_move( $square, $col - 1, $row - 1 ) ) {
            push @moves, $m if $m->{capture};
        }

        # forward
        if ( my $m = can_move( $square, $col, $row - 1 ) ) {
            unless ( $m->{capture} ) {
                push @moves, $m;
                if ( 7 == $row ) {
                    if ( my $m = can_move( $square, $col, $row - 2 ) ) {
                        push @moves, $m;
                    }
                }
            }
        }
    }
    return @moves;
}

sub play {
    my ($move)   = @_;
    my $from_col = $move->{from}->{col};
    my $from_row = $move->{from}->{row};
    my $to_col   = $move->{col};
    my $to_row   = $move->{row};
    my $square   = $board[$from_col][$from_row];
    $board[$from_col][$from_row] = undef;
    $board[$to_col][$to_row]     = {
        piece => $square->{piece},
        col   => $to_col,
        row   => $to_row,
        color => $square->{color},
    };
}

sub back {
    my ($move)   = @_;
    my $from_col = $move->{from}->{col};
    my $from_row = $move->{from}->{row};
    my $to_col   = $move->{col};
    my $to_row   = $move->{row};
    my $square   = $board[$to_col][$to_row];
    $board[$to_col][$to_row]     = $move->{capture};
    $board[$from_col][$from_row] = {
        piece => $square->{piece},
        col   => $from_col,
        row   => $from_row,
        color => $square->{color},
    };
}

sub inv_color {
    my ($color) = @_;
    return !( $color || 0 );
}

sub king_in_check {
    my ($color) = @_;
    for my $m ( get_all_moves( inv_color($color) ) ) {
        next unless my $cap = $m->{capture};
        next unless $cap->{piece} == KING;
        return 1;
    }
    return 0;
}

sub can_move {
    my ( $square, $col, $row ) = @_;
    return if ( $row < 1 ) || ( $row > 8 );
    return if ( $col < 1 ) || ( $col > 8 );
    my $dest = $board[$col][$row];
    return
      if ($dest) && ( $dest->{color} == $square->{color} );
    return {
        from    => $square,
        col     => $col,
        row     => $row,
        capture => $dest,
    };
}

sub get_all_moves {
    my ($color) = @_;
    my @moves;
    for my $col ( 1 .. 8 ) {
        for my $row ( 1 .. 8 ) {
            my $square = $board[$col][$row];
            next unless $square;
            next unless $square->{color} eq $color;
            my @m;
            if ( KING == $square->{piece} ) {
                @m = king($square);
            } elsif ( QUEEN == $square->{piece} ) {
                @m = queen($square);
            } elsif ( ROCK == $square->{piece} ) {
                @m = rock($square);
            } elsif ( BISHOP == $square->{piece} ) {
                @m = bishop($square);
            } elsif ( KNIGHT == $square->{piece} ) {
                @m = knight($square);
            } elsif ( PAWN == $square->{piece} ) {
                @m = pawn($square);
            } else {
                die "unknown piece\n";
            }

            @moves = ( @moves, @m );
        }
    }
    return @moves;
}

sub get_valid_moves {
    my ($color) = @_;
    my @moves;
    for my $m ( get_all_moves($color) ) {
        play($m);
        my $in_check = king_in_check($color);
        back($m);
        push @moves, $m unless $in_check;
    }
    return @moves;
}

sub display_board {
    my $pieces = {    # Unicode chess symbols
        &KING   => { &WHITE => 0x2654, &BLACK => 0x265a },
        &QUEEN  => { &WHITE => 0x2655, &BLACK => 0x265b },
        &ROCK   => { &WHITE => 0x2656, &BLACK => 0x265c },
        &BISHOP => { &WHITE => 0x2657, &BLACK => 0x265d },
        &KNIGHT => { &WHITE => 0x2658, &BLACK => 0x265e },
        &PAWN   => { &WHITE => 0x2659, &BLACK => 0x265f },
    };

    binmode( STDOUT, ':utf8' );
    for my $row (qw / 8 7 6 5 4 3 2 1/) {
        for my $col ( 1 .. 8 ) {
            print " ";
            if ( my $sq = $board[$col][$row] ) {
                my $p = $sq->{piece};
                my $c = $sq->{color};
                print chr( $pieces->{$p}->{$c} );
            } else {
                print chr(0xb7);    # unicode middle dot
            }
        }
        print "   $row\n";
    }
    print " A B C D E F G H\n\n";
}

=item read_board()
 Read board setup from stdin.

 Data format: <piece><square>

 Pieces:
    K|k – king
    Q|q – queen
    R|r – rock
    N|n – knight
    B|b – bishop
    P|p – pawn
 where:
   [KQRNBP] – white pieces
   [kqrnbp] – black pieces
=cut

sub read_board {

    my $pieces = {
        K => KING,
        Q => QUEEN,
        R => ROCK,
        B => BISHOP,
        N => KNIGHT,    # N because K is for king
        P => PAWN,
    };

    while (<>) {
        chomp;
        s{\s}{}g;
        next if m{^#};
        next unless $_;
        die "Invalid input!\n"
          . "Valid format is: [bknpqrBKNPQR]\\s*[a-zA-Z]\\s*[1-8] per line"
          unless m{^([bknpqr])([a-z])([1-8])$}i;
        my ( $p, $c, $row ) = ( $1, $2, $3 );
        my $col = ord( uc($c) ) - ord('A') + 1;
        $board[$col][$row] = {
            piece => $pieces->{ uc($p) },
            col   => $col,
            row   => $row,
            color => ( uc($p) eq $p ) ? WHITE : BLACK,
        };
    }
}
###############################################################################
#
# Let's rock!
#

read_board();

display_board();

for my $w1move ( get_valid_moves(WHITE) ) {
    play($w1move);
    my $this_wins = 1;
    for my $b1move ( get_valid_moves(BLACK) ) {
        play($b1move);
        my $checkmate = 0;
        for my $w2move ( get_valid_moves(WHITE) ) {
            play($w2move);
            if ( king_in_check(BLACK) ) {
                $checkmate = 1 unless get_valid_moves(BLACK);
            }
            back($w2move);
            last if $checkmate;
        }
        back($b1move);
        $this_wins = 0 unless $checkmate;
        last unless $this_wins;
    }
    back($w1move);

    if ($this_wins) {

        # TODO move notation
        printf "%s%d -> %s%d and white wins in next move.\n",
          chr( 64 + $w1move->{from}->{col} ), $w1move->{from}->{row},
          chr( 64 + $w1move->{col} ), $w1move->{row};
    }
}
