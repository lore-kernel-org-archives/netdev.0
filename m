From: Daniele Lacamera <root@danielinux.net>
Subject: Re: TCP Pacing
Date: Wed, 13 Sep 2006 17:46:00 +0200
Message-ID: <200609131746.03679.root@danielinux.net>
References: <200609121958.22820.root@danielinux.net> <5640c7e00609121426t75f5519at562a85f40b64163@mail.gmail.com> <200609131018.40023.root@danielinux.net>
Reply-To: root@danielinux.net
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Carlo Caini <ccaini@deis.unibo.it>,
	Rosario Firrincieli <rfirrincieli@arces.unibo.it>,
	Giovanni Pau <gpau@cs.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from danielinux.vm.bytemark.co.uk ([80.68.95.85]:8965 "EHLO
	danielinux.vm.bytemark.co.uk") by vger.kernel.org with ESMTP
	id S1750964AbWIMPqG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 11:46:06 -0400
To: root@danielinux.net, Ian McDonald <ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609131018.40023.root@danielinux.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As Ian requested, some of the papers published about Pacing.

* Main reference:
-----------------

Amit Aggarwal, Stefan Savage, and Thomas Anderson.  =20
"Understanding the Performance of TCP Pacing".=20
Proc. of the IEEE INFOCOM 2000 Conference on Computer Communications,=20
March 2000, pages 1157 - 1165.

* IETF RFC:
-----------

H. Balakrishnan, V. N. Padmanabhan, G. Fairhurst, M.Sooriyabandara,=20
"TCP Performance Implications of Network Path Asymmetry",
IETF RFC 3449, December 2002.

* Other works:
--------------

C. Caini, R. Firrincieli,=20
"Packet spreading techniques to avoid bursty traffic in satellite TCP=20
connections".=20
In. Proceedings of IEEE VTC Spring =E2=80=9904

Q.Ye, M.H. MacGregor,=20
"Pacing to Improve SACK TCP Resilience",=20
2005 Spring Simulation Multiconference, DASD, pp. 39-45, 2005

Young-Soo Choi; Kong-Won Lee; Tae-Man Han; You-Ze Cho;
"High-speed TCP protocols with pacing for fairness and TCP friendliness=
"
TENCON 2004. 2004 IEEE Region 10 Conference
Volume C,=C2=A0 21-24 Nov. 2004 Page(s):13 - 16 Vol. 3=20

Razdan, A.; Nandan, A.; Wang, R.; Sanadidi, M.Y.; Gerla, M.;
"Enhancing TCP performance in networks with small buffers"
Computer Communications and Networks, 2002. Proceedings. Eleventh=20
International Conference on
14-16 Oct. 2002 Page(s):39 - 44=20

Moonsoo Kang; Jeonghoon Mo;
"On the Pacing Technique for High Speed TCP Over Optical Burst Switchin=
g=20
Networks"
Advanced Communication Technology, 2006. ICACT 2006. The 8th=20
International Conference
Volume 2, 20-22 Feb. 2006 Page(s):1421 - 1424=20

Mark Allman, Ethan Blanton
"Notes on burst mitigation for transport protocols",=20
April 2005 ACM SIGCOMM Computer Communication Review, Volume 35 Issue 2=
=20
Publisher: ACM Press

J. Kulik, R. Coulter, D. Rockwell, and C. Partridge,=20
"A Simulation Study of Paced TCP",=20
BBN Technical Memorandum No. 1218, 1999.=20


* Congestion Control proposals that include Pacing:
---------------------------------------------------

G. Marfia, C. Palazzi, G. Pau, M. Gerla, M. Sanadidi and M. Roccetti,=20
"TCP Libra: Balancing Flows over Heterogeneous
Propagation Scenarios", submitted for publication in Proceedings of ACM=
=20
SIGMETRICS/Performance 2006.=20

Carlo Caini and Rosario Firrincieli,=20
"TCP Hybla: a TCP enhancement for heterogeneous networks",=20
INTERNATIONAL JOURNAL OF SATELLITE COMMUNICATIONS AND NETWORKING 2004;=20
22:547=E2=80=93566=20

D. X. Wei, C. Jin, S. H. Low and S. Hegde.
"FAST TCP: motivation, architecture, algorithms",=20
performance IEEE/ACM Transactions on Networking, to appear in 2007=20


--=20
Daniele Lacamera
root{at}danielinux.net
