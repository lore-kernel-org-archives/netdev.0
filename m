From: "Ian McDonald" <ian.mcdonald-WpNOhQBWTy6lP80pJB477g@public.gmane.org>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 5 Mar 2007 13:46:36 +1300
Message-ID: <5640c7e00703041646w32d7bc77s33d1fca4755a1b78@mail.gmail.com>
References: <20070304220857.GH23311@waste.org>
	 <1173051564.6131.13.camel@johannes.berg>
	 <20070305002550.GI23311@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Greg KH" <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, akpm-3NddpPZAyC0@public.gmane.org
To: "Matt Mackall" <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070305002550.GI23311-1tnLUEbcrg3YtjvyW6yDsg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/5/07, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org> wrote:
> > This is due to the recent sysfs restructuring I think. IIRC the fix is
> > to upgrade hal to a current git version.
>
> If that's the cause, the fix is to back out whatever was done to break
> userspace. Breaking userspace is not ok. Upgrading from 2.6.x to
> 2.6.x+1 should not entail replacing substantial parts of userspace,
> especially with NOT-EVEN-FRAKKING-RELEASED-YET CODE.
>
> I will try a new HAL when it shows up in Debian/unstable and not a
> moment sooner.
>
But you're running a kernel that's not in Debian/unstable so this
seems a bit hypocritical.

When you work with bleeding edge kernels you have to be prepared to
work around things. Hell for ages git wasn't in Debian - unstable
even, udev would break things etc.

Just my 2c worth.
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
