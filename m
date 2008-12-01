From: "Kaplowitz, David" <dkaplowitz@irobot.com>
Subject: multicast forwarding
Date: Mon, 1 Dec 2008 14:08:51 -0500
Message-ID: <1228158531.8392.83.camel@irbt-1279>
Reply-To: "Kaplowitz, David" <dkaplowitz@irobot.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-Vj7xpE0Lc+roQZN8NoCc"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.irobot.com ([206.83.81.187]:16848 "EHLO smtp1.irobot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752550AbYLATIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 14:08:53 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Vj7xpE0Lc+roQZN8NoCc
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Greetings,

I have an interesting difficulty.  I want to be able to grab a multicast
stream from a machine (192.168.12.13) and forward/rebroadcast/rewrite
it, such that the packets seem to come from my DMZ host (192.168.12.12).

I have been trying an iptables solution, but that doesn't seem to be
working at the moment, and it was recommended to me by =EF=BB=BFj_engelh on=
 the
#iptables channel to ask at this address for further assistance.

Thank you for your time and effort on my behalf.

-dkap

Below is three representative packets:

U 192.168.12.13:6970 -> 224.0.1.20:6990
  ...@.7..........U`c.|?...^v/9.....?.....E......{.......^../..W....o.Q..;.=
..
  ....:'.S.~.....fv.......1xe................y...|Q.....3.@.u..........=3D.=
....
  .^0.........0.B.`.^............{../.....B..UY....Z.....Te....H........^..=
..
  .'...._..<.!..^b/7.....b..3.s.."....X......B.NL&...*.V..C.../|^o.T@......=
O.
  =3D.7..Nc...R....Vku...X8.`8A$.....]..Qy8......[...)3x./.?.n.......qy.   =
   =20
#
U 192.168.12.13:6970 -> 224.0.1.20:6990
  ...A.7..........U.S.}..../;......b..........fN.........O.^0.cA..t...b._W.=
..
  ./.:/......D..X^5.1....^.y'./.$.Z....-*..r.`.<^I...x...+.......-SVa.....N=
..
  ...;.]...=3D.......lJ..mO...<o.u"......2....I6. ./:/</5.y.^t/.YX..._O....=
.F..
  ...\...V...............y.x.p^...0X....q~..^w.......D...C..h.M...,../..o.b=
1.
  pN/.|^L*....B."v/w......!.8......p.0$D.+c.Qx1._.@...{ ..5....Y._.8.......=
..
  .h._.............f..R..^.yIP......L.d+.8.......8....?.xV.>....J.CfZ..1..p=
*.
  88Z.f.....@ ./'........:.c..0..:E.aO...B.h.....P.....r........T....%..K..=
..
  @J~...{...`q.q.g9J..PK....4-..kM.b..|..{....._.. GT..|........1y4^.......=
..
  ./....                                                                   =
 =20
#
U 192.168.12.13:6970 -> 224.0.1.20:6990
  .`.B.7.u....... ....$. ...h.H...X ........`.....4Z.z....v..Gw...~..|.....=
..
  T...hc...Q..knj7Y.`....|6%..LpS...wt.....s.|{i.}.....y.P5....(..q.e;.Z.H.=
..
  8O..nH.iw...t..I.....<.....&......y6..,b...Tk..k^.Z._.S./.Ny..C}.9cu..0..=
.q
  O.........R.z:.u..-L..}.rPV.6.x.P....O.....?.....?..NO..?'..\...V.:....lp=
.!
  ..W..iar...B.aD.....^.....B.!..KXK...f....u....^:VEa|g.O...apq........~..=
%.
  ...%....d......y....P.Tz.....-..|.3...U@u.<b....P.^AMV.....U..D.u..n.....=
..
  rj.*F..t...O.u A`:.@.......x....*gA.Fv.c`......2%'...[Z.FWJ.I...2.FV...VS=
..
  G....69....W)]...W.E...O*......R......S..F...Ug...Y.}..p...U.......Z.5...=
..
  r.i...FT%C....n.%.Uu&!.j.).7.3.....V'j.....?..D.pl..h->@Z...Z...7...y....=
..
  ..$.$\......e.@.$*.h.{'......EE|.2z.+z.5....x....ul..@.4.$G.....r..N.<bp<=
c.
  ....P......-.?..P....O....:..t......&....L.t..ggu'%........Nuq5'....N>.q.=
uD
  1..W...I....,^....5.`......z.o.......3.V...r...QEf...v...!..x.x..<4.?.e.1=
.]
  S..IJ...0 ......P.......x..i-....* .a8.A7........R..l2U.......e4t.g......=
.p
  ..aw....e......H.c.....h*...d.}....aK..........P...(...De..V...c.....PF..=
.8
  ......@y..2'....\..G..~x.F^/fl.0...TY...g.<..)L9.MR...d.S8.QF.%...z.....0=
.^
  ...........5...............GlYT.^#c.L.._Ur..\\..;r%^.*.M@..5H.T.o.s...2..=
T.
  .g...?..b......?FwR.M....s...NN..h..&~.....".<.F.&.uN..=3D..........pb4U.=
....
  p..5......&.4.L.p-.C.oB..C...%^].e.`..#......6..z.2......2...<.h0a....E")=
..
  .v.@.@M..t......0DS.L0.=3DO.}M6$Mf..."....1j..-.#Yi....a.3#...i.>.....}^.=
W...
  .)C.JL...... .q...F....ss..S...1.)L!.C.fh\...V.  =20

--=-Vj7xpE0Lc+roQZN8NoCc
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBJNDZDueMqKH4VzoYRArfDAKCLEoUzfzQxM6g19/dKlPq462v42wCfVDfO
l57mSZnr10Je+vTvCyGng5c=
=2W5U
-----END PGP SIGNATURE-----

--=-Vj7xpE0Lc+roQZN8NoCc--
