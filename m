From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [rfc 0/4] igb: bandwidth allocation
Date: Wed, 4 Nov 2009 17:46:50 -0800
Message-ID: <9929d2390911041746g2b5f51cdia489bd87d87e41ef@mail.gmail.com>
References: <20091105005847.941190065@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Arnd Bergmann <arndbergmann@googlemail.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20091105005847.941190065@vergenet.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Nov 4, 2009 at 16:58, Simon Horman <horms@verge.net.au> wrote:
> Hi,
>
> this series of patches exposes the bandwidth allocation
> hardware support of the Intel 82576. It does so through
> a rather hackish sysfs entry. That interface is just intended
> for testing so that the exposed hardware feature can
> be exercised. I would like to find a generic way to expose
> this feature to user-space.
>

Thanks Simon.  I have add the 4 patch series to my tree for testing.

-- 
Cheers,
Jeff

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
