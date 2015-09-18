From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 3/6] comment: Fix remaining listings of wrong FSF address
Date: Fri, 18 Sep 2015 20:17:02 +0200
Message-ID: <1442600225-18355-4-git-send-email-phil@nwl.cc>
References: <1442600225-18355-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:59321 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752149AbbIRSRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2015 14:17:08 -0400
In-Reply-To: <1442600225-18355-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch follows the changes of commit 4d98ab0 ("Fix FSF address in
file headers"), fixing file headers added after it.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/linux/tc_act/tc_skbedit.h | 3 +--
 tc/m_connmark.c                   | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/linux/tc_act/tc_skbedit.h b/include/linux/tc_act/tc_skbedit.h
index 7a2e910..73026b3 100644
--- a/include/linux/tc_act/tc_skbedit.h
+++ b/include/linux/tc_act/tc_skbedit.h
@@ -11,8 +11,7 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
+ * this program; if not, see <http://www.gnu.org/licenses>.
  *
  * Author: Alexander Duyck <alexander.h.duyck@intel.com>
  */
diff --git a/tc/m_connmark.c b/tc/m_connmark.c
index 51938dc..41ca4b2 100644
--- a/tc/m_connmark.c
+++ b/tc/m_connmark.c
@@ -13,8 +13,7 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
+ * this program; if not, see <http://www.gnu.org/licenses>.
  */
 
 #include <stdio.h>
-- 
2.1.2
