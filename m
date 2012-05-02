From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [V2 PATCH 0/9] vhost/macvtap zeropcopy fixes
Date: Wed, 2 May 2012 11:11:43 +0300
Message-ID: <20120502081141.GA30549@redhat.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
 <20120502055008.GA29319@redhat.com>
 <20120502.024427.22049954455309204.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120502.024427.22049954455309204.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 02, 2012 at 02:44:27AM -0400, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Wed, 2 May 2012 08:50:09 +0300
> 
> > On Wed, May 02, 2012 at 11:41:21AM +0800, Jason Wang wrote:
> >> This is an updated since the last series of vhost/macvtap zerocopy fixes which
> >> fixes the the possible transmission stall, host kernel stack overflow and other
> >> misc fixes.
> >> 
> >> Changes from V1:
> >> - Addressing comments from Eric and Michael.
> >> - Adding more fixes into the seires.
> > 
> > Thanks for fixing this.
> > Acked-by: Michael S. Tsirkin <mst@redhat.com>
> > 
> > Dave, can you merge this for 3.4 please?
> 
> It's rather late in the -RC for such a large patch set.

I was in doubt that's why I asked instead of just merging through my tree.
OK, I'll apply to my tree and send pull request for net-next a bit later.
-- 
MST
