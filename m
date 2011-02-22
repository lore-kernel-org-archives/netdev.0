From: Randy Dunlap <rdunlap@xenotime.net>
Subject: net: update Documentation/networking/00-INDEX
Date: Tue, 22 Feb 2011 14:23:43 -0800
Message-ID: <20110222142343.f3318134.rdunlap@xenotime.net>
References: <4D6095E3.2040103@parallels.com>
	<20110221185205.GA23284@mako-laptop>
	<4D62C43F.5040302@parallels.com>
	<20110221120303.48106f6c.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rob Landley <rlandley@parallels.com>,
	Mariusz Kozlowski <mk@lab.zgora.pl>,
	LKML <linux-kernel@vger.kernel.org>, <linux-doc@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>, davem@davemloft.net
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20110221120303.48106f6c.rdunlap@xenotime.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Clean up entries in 00-INDEX: drop files that have been removed.

Reported-by: Rob Landley <rlandley@parallels.com>
Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 Documentation/networking/00-INDEX |    6 ------
 1 file changed, 6 deletions(-)

--- linux-next-20110222.orig/Documentation/networking/00-INDEX
+++ linux-next-20110222/Documentation/networking/00-INDEX
@@ -40,8 +40,6 @@ decnet.txt
 	- info on using the DECnet networking layer in Linux.
 depca.txt
 	- the Digital DEPCA/EtherWORKS DE1?? and DE2?? LANCE Ethernet driver
-dgrs.txt
-	- the Digi International RightSwitch SE-X Ethernet driver
 dmfe.txt
 	- info on the Davicom DM9102(A)/DM9132/DM9801 fast ethernet driver.
 e100.txt
@@ -50,8 +48,6 @@ e1000.txt
 	- info on Intel's E1000 line of gigabit ethernet boards
 eql.txt
 	- serial IP load balancing
-ethertap.txt
-	- the Ethertap user space packet reception and transmission driver
 ewrk3.txt
 	- the Digital EtherWORKS 3 DE203/4/5 Ethernet driver
 filter.txt
@@ -104,8 +100,6 @@ tuntap.txt
 	- TUN/TAP device driver, allowing user space Rx/Tx of packets.
 vortex.txt
 	- info on using 3Com Vortex (3c590, 3c592, 3c595, 3c597) Ethernet cards.
-wavelan.txt
-	- AT&T GIS (nee NCR) WaveLAN card: An Ethernet-like radio transceiver
 x25.txt
 	- general info on X.25 development.
 x25-iface.txt
