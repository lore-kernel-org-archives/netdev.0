From: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v18 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve
 from granting privs
Date: Fri, 13 Apr 2012 22:06:31 -0500
Message-ID: <CABqD9hahg_KJHTFnRCDpUFaa4TZjy_2EvVOqtd89NvTnr8UkSw@mail.gmail.com>
References: <1334267284-19166-1-git-send-email-wad@chromium.org>
	<alpine.LRH.2.02.1204141143001.29389@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org,
	mcgrathr-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, luto-3s7WtUTddSA@public.gmane.org,
	eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, djm-ilwOsaqNJrtAfugRpC6u6w@public.gmane.org,
	scarybeasts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, indan-1J6HnF7K7zE@public.gmane.org, pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, corbet-T1hC0tSOHrs@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	markus-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, coreyb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
To: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LRH.2.02.1204141143001.29389-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 13, 2012 at 8:45 PM, James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org> wrote:
> I applied the patchset to:
> git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/linux-security.git next
>
> Please test, and make any further updates against that branch.

Great! I will most certainly do that.

Thanks!
will
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
