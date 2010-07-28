From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [patch -next] ixgbe: potential null dereference
Date: Tue, 27 Jul 2010 17:10:02 -0700
Message-ID: <AANLkTim5LGj0KGs-0fGGAka7Fde3=NVVXWYBLbb_kVMs@mail.gmail.com>
References: <20100727100556.GM26313@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Dan Carpenter <error27@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100727100556.GM26313@bicker>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Jul 27, 2010 at 03:05, Dan Carpenter <error27@gmail.com> wrote:
> The e_dev_err() macro dereferences "adapter" which is NULL here.
>
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

------------------------------------------------------------------------------
The Palm PDK Hot Apps Program offers developers who use the
Plug-In Development Kit to bring their C/C++ apps to Palm for a share 
of $1 Million in cash or HP Products. Visit us here for more details:
http://ad.doubleclick.net/clk;226879339;13503038;l?
http://clk.atdmt.com/CRS/go/247765532/direct/01/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
