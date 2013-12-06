From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool] ethtool: Fix FSF address in file headers
Date: Fri,  6 Dec 2013 11:32:00 -0800
Message-ID: <1386358320-26283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43795 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753417Ab3LFTcX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 14:32:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several files refer to an old address for the Free Software Foundation
in the file header comment.  Resolve by replacing the address with
the URL <http://www.gnu.org/licenses/> so that we do not have to keep
updating the header comments anytime the address changes.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 COPYING | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/COPYING b/COPYING
index d60c31a..ea117cd 100644
--- a/COPYING
+++ b/COPYING
@@ -1,8 +1,7 @@
 		    GNU GENERAL PUBLIC LICENSE
 		       Version 2, June 1991
 
- Copyright (C) 1989, 1991 Free Software Foundation, Inc.
-     59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ Copyright (C) 1989, 1991 Free Software Foundation, Inc. <http://fsf.org/>
  Everyone is permitted to copy and distribute verbatim copies
  of this license document, but changing it is not allowed.
 
@@ -304,8 +303,7 @@ the "copyright" line and a pointer to where the full notice is found.
     GNU General Public License for more details.
 
     You should have received a copy of the GNU General Public License
-    along with this program; if not, write to the Free Software
-    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+    along with this program; if not, see <http://www.gnu.org/licenses/>.
 
 
 Also add information on how to contact you by electronic and paper mail.
-- 
1.8.3.1
