From: Daniel Drake <ddrake@brontes3d.com>
Subject: ar5k and Atheros AR5005G
Date: Tue, 28 Nov 2006 15:39:12 -0500
Message-ID: <1164746352.31456.22.camel@systems03.lan.brontes3d.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <madwifi-devel-bounces@lists.sourceforge.net>
To: madwifi-devel@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/madwifi-devel>,
	<mailto:madwifi-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=madwifi-devel>
List-Post: <mailto:madwifi-devel@lists.sourceforge.net>
List-Help: <mailto:madwifi-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/madwifi-devel>,
	<mailto:madwifi-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: madwifi-devel-bounces@lists.sourceforge.net
Errors-To: madwifi-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

I'm interested in porting the ar5k driver to Linux after the recent SFLC
conclusions on the legal status. However, the hardware I have here
appears to be unsupported by ar5k:

01:04.0 0200: 168c:001a (rev 01)
        Subsystem: 168c:2052

01:04.0 Ethernet controller: Atheros Communications, Inc. AR5005G
802.11abg NIC (rev 01)
        Subsystem: Atheros Communications, Inc. Unknown device 2052
        Flags: bus master, medium devsel, latency 168, IRQ 66
        Memory at c0100000 (32-bit, non-prefetchable) [size=64K]
        Capabilities: [44] Power Management version 2

It is a mini-PCI card.

Does anyone know how much work would be needed for the ar5k codebase to
support this hardware?

Thanks!
-- 
Daniel Drake
Brontes Technologies, A 3M Company


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
