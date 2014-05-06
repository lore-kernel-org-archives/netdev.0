From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 22:07:38 +0200
Message-ID: <20140506200738.GA17813@netboy>
References: <20140506032114.GP2382@two.firstfloor.org>
 <20140505.232327.578134514220748085.davem@davemloft.net>
 <20140506155703.GA20391@cloud>
 <20140506.115941.428706504757835279.davem@davemloft.net>
 <20140506164108.GA20536@cloud>
 <20140506191447.GB4137@netboy>
 <20140506195049.GO19657@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: josh@joshtriplett.org, David Miller <davem@davemloft.net>,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com
To: Andi Kleen <ak@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140506195049.GO19657@tassilo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 06, 2014 at 12:50:49PM -0700, Andi Kleen wrote:
> 
> > So I think Dave is right
> > in rejecting anything that compromises the _quality_ of the stack.
> 
> I don't think anything I removed compromised quality (modulo bugs)
> It's still a more-features-than-your-typical-BSD TCP/IP stack

But Dave seems to think so.

My (obvious?) point is, if you make the stack different, and not just
smaller by omitting optional features, then that defeats the point of
wanting the Linux stack in the first place.

Thanks,
Richard
