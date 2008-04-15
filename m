From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/3] igb: save and restore pcie/msi state to
	support EEH	recovery
Date: Tue, 15 Apr 2008 10:57:57 -0700
Message-ID: <20080415175757.12506.3922.stgit@localhost.localdomain>
References: <20080415175745.12506.67349.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	wendyx@us.ibm.com
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080415175745.12506.67349.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

To enable EEH support for pci-express network adapters, pcie/msi state
needs to be saved and restored for that adapter.

[after similar patches for ixgbe and e1000e from Wendy Xiong]

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Wendy Xiong <wendyx@us.ibm.com>
---

 0 files changed, 0 insertions(+), 0 deletions(-)



-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
