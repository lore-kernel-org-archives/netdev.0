From: John Levon <levon@movementarian.org>
Subject: [PATCH] remove net/README
Date: Thu, 4 Sep 2003 15:52:04 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030904145204.GA27953@compsoc.man.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This file seems bitrotted and more up to date info is available in
MAINTAINERS in large part.

regards
john


diff -Naur -X dontdiff linux-cvs/net/README linux-fixes/net/README
--- linux-cvs/net/README	2002-02-06 00:13:33.000000000 +0000
+++ linux-fixes/net/README	1970-01-01 01:00:00.000000000 +0100
@@ -1,26 +0,0 @@
-
-Maintainers and developers for networking code sections
-
-Code Section		Bug Report Contact
--------------------+-------------------------------------------
-802 [other	]	alan@lxorguk.ukuu.org.uk	
-    [token ring	]	p.norton@computer.org
-appletalk		jschlst@samba.org
-ax25			g4klx@g4klx.demon.co.uk
-bridge			buytenh@gnu.org
-core			alan@lxorguk.ukuu.org.uk
-decnet			SteveW@ACM.org
-ethernet		alan@lxorguk.ukuu.org.uk
-ipv4			davem@caip.rutgers.edu,Eric.Schenk@dna.lth.se
-ipv6			davem@caip.rutgers.edu,Eric.Schenk@dna.lth.se
-ipx			acme@conectiva.com.br
-spx			jschlst@samba.org
-irda                    dagb@cs.uit.no
-lapb			g4klx@g4klx.demon.co.uk
-netrom			g4klx@g4klx.demon.co.uk
-rose			g4klx@g4klx.demon.co.uk
-wanrouter		gene@compuserve.com, jaspreet@sangoma and dm@sangoma.com
-unix			alan@lxorguk.ukuu.org.uk
-x25			g4klx@g4klx.demon.co.uk
-bluetooth		maxk@qualcomm.com
-8021q                   greearb@candelatech.com, vlan@scry.wanfear.com
