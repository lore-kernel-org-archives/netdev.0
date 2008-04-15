From: "Michael Kerrisk" <mtk.manpages@gmail.com>
Subject: Re: Reporting bugs and bisection
Date: Tue, 15 Apr 2008 11:54:18 +0200
Message-ID: <517f3f820804150254w491cdf85s28f1d15696db8d96@mail.gmail.com>
References: <47FEADCB.7070104@rtr.ca> <20080413205406.GA9190@2ka.mipt.ru>
	 <48028830.6020703@earthlink.net>
	 <alpine.DEB.1.10.0804131546370.9318@asgard>
	 <20080414043939.GA6862@1wt.eu>
	 <20080414053943.GU9785@ZenIV.linux.org.uk>
	 <20080413232441.e216a02c.akpm@linux-foundation.org>
	 <20080414072328.GW9785@ZenIV.linux.org.uk>
	 <Xine.LNX.4.64.0804150131300.4160@us.intercode.com.au>
	 <4804765B.2070300@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "James Morris" <jmorris@namei.org>,
	"Al Viro" <viro@zeniv.linux.org.uk>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Willy Tarreau" <w@1wt.eu>, david@lang.hm,
	"Stephen Clark" <sclark46@earthlink.net>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Tilman Schmidt" <tilman@imap.cc>, Valdis.Kletnieks@vt.edu,
	"Mark Lord" <lkml@rtr.ca>, "David Miller" <davem@davemloft.net>,
	jesper.juhl@gmail.com, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel <linux-kernel@vger.kernel.org>, git@vger.kernel.org,
	netdev@vger.kernel.org
To: "David Newall" <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:40604 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757832AbYDOJyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 05:54:19 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1934409fgb.17
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 02:54:18 -0700 (PDT)
In-Reply-To: <4804765B.2070300@davidnewall.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/15/08, David Newall <davidn@davidnewall.com> wrote:
> James Morris wrote:
>  > I don't know how to solve this, but suspect that encouraging the use of
>  > reviewed-by and also including it in things like analysis of who is
>  > contributing, selection for kernel summit invitations etc. would be a
>  > start.  At least, better than nothing.
>
> Would it be hard to keep count of the number of errors introduced by
>  author and reviewer?

I've found quite a few errors in kernel-userland APIs, but I'm not
sure that this sort of negative statistic would be helpful -- e.g.,
more productive developers probably also introduce more errors.

-- 
I'll likely only see replies if they are CCed to mtk.manpages at gmail dot com
