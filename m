From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bug #16626] Machine hangs with EIP at skb_copy_and_csum_dev
Date: Tue, 31 Aug 2010 21:26:59 +0200
Message-ID: <20100831192659.GA3093@del.dom.local>
References: <4LwrqITm-eJ.A.r8G.eFueMB@chimera>
 <4AUWBNzTkbD.A.ey.cGueMB@chimera>
 <courier.4C7C99F2.00001F74@fs.ru.acad.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Plamen Petrov <pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <courier.4C7C99F2.00001F74-Xdw7EbNJKi3354cJYj5R/Q@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 31, 2010 at 08:58:10AM +0300, Plamen Petrov wrote:
> Rafael J. Wysocki ????????????:
> 
> >This message has been generated automatically as a part of a summary report
> >of recent regressions.
> >
> >The following bug entry is on the current list of known regressions
> >from 2.6.35.  Please verify if it still should be listed and let the tracking team
> >know (either way).
> >
> >
> >Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16626
> >Subject		: Machine hangs with EIP at skb_copy_and_csum_dev
> >Submitter	: Plamen Petrov <pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
> >Date		: 2010-08-19 09:57 (11 days old)
> >Handled-By	:  Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >
> >
> 
> Should "generic receive offload" work on a forwarding setup?
> If yes - then the bug should remain open.
> If not - then it's my mistake.

If/since it's on by default it should work and it definitely can't be
your mistake. (Unless we can't find the real reason... ;-)

Jarek P.
