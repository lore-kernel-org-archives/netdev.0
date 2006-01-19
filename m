From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [Bcm43xx-dev] wireless: the contenders
Date: Thu, 19 Jan 2006 10:27:46 -0500
Message-ID: <20060119152741.GA12344@tuxdriver.com>
References: <20060118200616.GC6583@tuxdriver.com> <1137629980.4385.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbenc@suse.cz, softmac-dev@sipsolutions.net,
	bcm43xx-dev@lists.berlios.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161237AbWASP2O@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1137629980.4385.9.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 19, 2006 at 01:19:40AM +0100, Johannes Berg wrote:
> On Wed, 2006-01-18 at 15:06 -0500, John W. Linville wrote:
> 
> > The tree also has "softmac" and "dscape" branches.  The "softmac"
> > branch includes the Johannes Berg softmac code as well as the the
> > BCM43xx driver based upon that code.
> 
> I guess that branch also contains my enhancements to ieee80211, do you
> have any intentions of pulling those over to your upstream tree? I
> suppose I should rather post them as a series of patches to netdev for
> wider consideration.

I pulled from the softmac-2.6.git tree.  I think there was ieee80211
stuff in there as well, but you probably know better than I do. :-)

The history in your tree isn't formatted properly for the kernel,
so something would have to be done before that went upstream anyway.
I think it would be best for you to post the patches to netdev,
including patches covering softmac if you are so inclined.  Please be
sure to follow kernel patch posting conventions:

	http://linux.yyz.us/patch-format.html

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
