From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 0/2] Fix some typos and an excessive
	space character
Date: Sat,  2 Aug 2014 20:37:09 -0600
Message-ID: <1407026820-26552-1-git-send-email-mysctp@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Linux NICS <linux.nics@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	<aaron.f.brown@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This small series fixes some typos in the kernel doc and an
excessive space character in the debug message. Both are associated
with e1000_mng_enable_host_if() of the Intel e1000e driver.

Please apply in the order as annotated.

Jean Sacren (2):
  e1000e: delete excessive space character in debug message
  e1000e: fix trivial kernel doc typos

 drivers/net/ethernet/intel/e1000e/manage.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)


------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
