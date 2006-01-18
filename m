From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [Bcm43xx-dev] wireless: the contenders
Date: Wed, 18 Jan 2006 15:25:27 -0500
Message-ID: <20060118202523.GD6583@tuxdriver.com>
References: <20060118200616.GC6583@tuxdriver.com> <200601182119.20708.mbuesch@freenet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbenc@suse.cz, softmac-dev@sipsolutions.net,
	bcm43xx-dev@lists.berlios.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030419AbWARU0Q@vger.kernel.org>
To: Michael Buesch <mbuesch@freenet.de>
Content-Disposition: inline
In-Reply-To: <200601182119.20708.mbuesch@freenet.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 18, 2006 at 09:19:20PM +0100, Michael Buesch wrote:
> On Wednesday 18 January 2006 21:06, John W. Linville wrote:
> > The tree also has "softmac" and "dscape" branches.  The "softmac"
> > branch includes the Johannes Berg softmac code as well as the the
> > BCM43xx driver based upon that code.  The "dscape" branch includes
> > the DeviceScape patches from Jiri Benc as well as the BCM43xx driver
> > ported to the DeviceScape stack.
> 
> Are you going to keep it synced with our repository?
> I think it should be possible to automatically send patches for
> every change in our tree to you. I am not 100% sure (but 99%).
> I will look at it tomorrow.

If you'll send me patches, I'll apply them...

John

P.S.  Please do what you can to make them comply w/ kernel patch
posting conventions:

	http://linux.yyz.us/patch-format.html
-- 
John W. Linville
linville@tuxdriver.com
