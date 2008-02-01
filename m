From: Doug Maxey <dwm@austin.ibm.com>
Subject: [PATCH 0/5] ehea checkpatch fixups
Date: Thu, 31 Jan 2008 20:20:46 -0600
Message-ID: <1201832451-23634-1-git-send-email-dwm@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux PowerPC List <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>, Jan-Bernd Themann <themann@de.ibm.com>
To: Jeff Garzik <jgarzik@garzik.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


A small set of fixups for checkpatch.

Based on upstream pull from a few hours ago.

 drivers/net/ehea/ehea.h         |    3 +
 drivers/net/ehea/ehea_ethtool.c |    4 +-
 drivers/net/ehea/ehea_hw.h      |    8 +-
 drivers/net/ehea/ehea_main.c    |   87 +++++++++++----------
 drivers/net/ehea/ehea_phyp.c    |  158 +++++++++++++++++++-------------------
 drivers/net/ehea/ehea_phyp.h    |   22 +++---
 drivers/net/ehea/ehea_qmr.c     |   32 ++++----
 drivers/net/ehea/ehea_qmr.h     |   16 ++--
 8 files changed, 169 insertions(+), 161 deletions(-)
