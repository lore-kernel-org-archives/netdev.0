From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2 5/5] stmmac: pci: remove FSF address
Date: Mon,  3 Nov 2014 15:02:17 +0200
Message-ID: <1415019737-32736-6-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1415019737-32736-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>,
	Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29190 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752300AbaKCNCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 08:02:36 -0500
In-Reply-To: <1415019737-32736-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FSF address is subject to change, thus remove it from the file.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 5084699..068ef8e 100644
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
