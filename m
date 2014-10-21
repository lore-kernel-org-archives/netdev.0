From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH 5/5] stmmac: pci: remove FSF address
Date: Tue, 21 Oct 2014 19:35:33 +0300
Message-ID: <1413909333-16380-6-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16292 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932520AbaJUUN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2014 16:13:59 -0400
In-Reply-To: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FSF address is subject to change, thus remove it from the file.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 22cb5ff..95eb195 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -12,10 +12,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
-- 
2.1.1
