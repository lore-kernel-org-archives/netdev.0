From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: borkage in 2.6.23-rc4-mm1
Date: Sat, 1 Sep 2007 09:12:49 -0400
Message-ID: <20070901131248.GA4462@tuxdriver.com>
References: <20070831211603.083dfed2.akpm@linux-foundation.org> <46D9352B.4060606@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46D9352B.4060606-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 01, 2007 at 05:47:23AM -0400, Jeff Garzik wrote:
> Andrew Morton wrote:
> >Aug 31 20:58:07 sony kernel: ipw2200: Firmware error detected.  Restarting.

> I see this on my Sony Vaio with older, non-mm kernels too.  Incredibly 
> frustrating, as it seems to be related to the phase of the moon. 
> Sometimes a reboot gets my wireless working, sometimes it doesn't.

There have been a few random reports of firmware restarts with ipw2x00
for a long time.  Unfortunately, only Intel has any visibility into
that firmware.  Do make sure you have the latest firmware released
from Intel (you probably do already, but it's worth checking).

Yi, any thoughts?

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
