From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 56/86] intel/ixgb: use
	uapi/linux/pci_ids.h directly
Date: Sun, 29 Mar 2015 22:30:36 -0700
Message-ID: <CAOaVG15C+4_+m-GFCB0V-G0fBGwj4fg7VsWmgwB+QNDWT136bA@mail.gmail.com>
References: <1427635734-24786-1-git-send-email-mst@redhat.com>
	<1427635734-24786-57-git-send-email-mst@redhat.com>
	<1427673301.2497.83.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6222601972634961440=="
Cc: Linux NICS <linux.nics@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	John Ronciak <john.ronciak@intel.com>, netdev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1427673301.2497.83.camel@jtkirshe-mobl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============6222601972634961440==
Content-Type: multipart/alternative; boundary=089e013c6a201c592905127ac823

--089e013c6a201c592905127ac823
Content-Type: text/plain; charset=UTF-8

Patch was rejected upstream by Greg

On Sun, Mar 29, 2015 at 4:55 PM, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
wrote:

> On Sun, 2015-03-29 at 15:41 +0200, Michael S. Tsirkin wrote:
> > Header moved from linux/pci_ids.h to uapi/linux/pci_ids.h,
> > use the new header directly so we can drop
> > the wrapper in include/linux/pci_ids.h.
> >
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >  drivers/net/ethernet/intel/ixgb/ixgb_hw.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Thanks Michael, I will add your patch to my queue.
> --
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
> dev-queue
>

--089e013c6a201c592905127ac823--


--===============6222601972634961440==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
--===============6222601972634961440==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============6222601972634961440==--
