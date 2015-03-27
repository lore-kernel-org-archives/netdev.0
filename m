From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] Intel Wired LAN Driver Updates
Date: Fri, 27 Mar 2015 16:04:10 -0700
Message-ID: <1427497451-23642-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, jogreene@redhat.com, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sassmann@redhat.com
To: davem@davemloft.net
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

The veil has been lifted...

No more having patches submitted against Intel wired Ethernet drivers
to be applied to a mysterious queue and not knowing what the status or
how many patches are in the queue.  We have created a new mailing list
(intel-wired-lan@lists.osuosl.org) for all Linux kernel patches and
kernel development, which anyone can subscribe to.  Also we have a
public patchwork project on patchwork.ozlabs.org, where all the
patches reside and their current status.

This change was made on part of the multiple requests for the community
and to also benefit from the various community testers.

Developers may also notice we have removed e1000-devel@lists.sourceforge.net
and the linux.nics@intel.com mailing lists from the MAINTAINERS file.
These mailing lists are not going away, their removal is an attempt to
focus their usage for their intended purpose.

The e1000-devel@lists.sourceforge.net mailing list will be used only
for our out-of-tree driver work and linux.nics@intel.com customer issues
and related work.

We had a "soft opening" March 24th, but now we are "officially" open
publicly for business. :-)`

The following are changes since commit dde93dfea53c72b07907d9e44a6e4b1545f6bdc4:
  cxgb4: Fix frame size warning for 32 bit arch
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue master

Jeff Kirsher (1):
  MAINTAINERS: Update Intel Wired Ethernet Driver info

 MAINTAINERS | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

-- 
1.9.3


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
