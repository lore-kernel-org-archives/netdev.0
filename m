From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [Bug #13328] b44: eth0: BUG! Timeout waiting for bit 00000002 of register 42c to clear.
Date: Mon, 24 Aug 2009 20:30:14 +0200
Message-ID: <200908242030.14414.rjw@sisk.pl>
References: <xDf-7eSwYsC.A.-6B.klIjKB@chimera> <200908201652.23574.rjw@sisk.pl> <38b2ab8a0908240041s7d9707eftb6e8078d7b6ad553@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Francis Moreau <francis.moro-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <38b2ab8a0908240041s7d9707eftb6e8078d7b6ad553-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 24 August 2009, Francis Moreau wrote:
> On Thu, Aug 20, 2009 at 4:52 PM, Rafael J. Wysocki<rjw-KKrjLPT3xs0@public.gmane.org> wrote:
> > On Thursday 20 August 2009, Francis Moreau wrote:
> >> Hello,
> >>
> >> On Wed, Aug 19, 2009 at 10:40 PM, Rafael J. Wysocki<rjw-KKrjLPT3xs0@public.gmane.org> wrote:
> >> > This message has been generated automatically as a part of a report
> >> > of regressions introduced between 2.6.29 and 2.6.30.
> >> >
> >> > The following bug entry is on the current list of known regressions
> >> > introduced between 2.6.29 and 2.6.30.  Please verify if it still should
> >> > be listed and let me know (either way).
> >> >
> >> >
> >> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=13328
> >> > Subject         : b44: eth0: BUG! Timeout waiting for bit 00000002 of register 42c to clear.
> >> > Submitter       : Francis Moreau <francis.moro-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >> > Date            : 2009-05-03 16:22 (109 days old)
> >> > References      : http://marc.info/?l=linux-kernel&m=124136778012280&w=4
> >> >
> >>
> >> It hasn't triggered on 2.6.31-rc5 after a couple of days.
> >
> > Great, let's assume it's fixed, then.
> 
> Sorry but it did happen this weekend.

That's OK, I'll reopen the bug.

Thanks,
Rafael
