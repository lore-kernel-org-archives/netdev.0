From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/9] wext: reduce inline abuse
Date: Thu, 26 Apr 2007 10:15:17 -0700
Message-ID: <20070426171517.GA22667@bougret.hpl.hp.com>
References: <20070424180732.371620000@sipsolutions.net> <20070424180849.651555000@sipsolutions.net> <20070426165032.GB22576@bougret.hpl.hp.com> <200704261903.27932.mb@bu3sch.de>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200704261903.27932.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2007 at 07:03:27PM +0200, Michael Buesch wrote:
> 
> Sure, other people have different opinions on that, but I think
> with my approach we get smallest code with good speed.

	Try with gcc-3.3 if you don't trust me. Your patch will
produce bigger and slower code. Thanks.

	Jean
