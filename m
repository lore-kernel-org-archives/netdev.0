From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 15:42:20 +0100
Message-ID: <20080424154220.3dae36a1@the-village.bc.nu>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
	<20080424112514.055d8071@the-village.bc.nu>
	<517f3f820804240534r3bbbdc52s52a6dfe3f2d14b7f@mail.gmail.com>
	<48109DFB.900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	michael.kerrisk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ulrich Drepper <drepper-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48109DFB.900-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Somebody please make a call and then let's go on with life.  I don't
> care much either way anymore.  I do hope nobody thinks this is an issue
> which can be completely ignored (see, e.g., the bug I pointed to the
> other day).

Its very hard to do that without knowing what other Unixlike and POSIX OS
plan to do and if we'll end up with a third yet again different API to
support when it reaches a standards body.

We shouldn't be seeing this as a Linux problem, its a BSD problem, an AIX
problem, a Solaris problem and an HPUX problem and really wants one
solution applying across distributions or it will harm everyone in the
long term.

Alan
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
