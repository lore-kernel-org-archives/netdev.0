From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC] Documentation: add documentation for rc-series and merge
	window
Date: Sun, 21 Jun 2009 08:24:58 +0200
Message-ID: <20090621062458.GC1474@ucw.cz>
References: <20090616004122.GC5492@tesla> <20090616021011.GF23972@bombadil.infradead.org> <20090616032034.GA17932@kroah.com> <20090616042113.GA5680@tesla> <20090616093401.GA11602@jm.kir.nu> <20090616181705.GB31506@tesla> <20090619150015.GC1389@ucw.cz> <43e72e890906191010v4b2e79a5x2c7b722b8209933c@mail.gmail.com> <20090619221909.GC2229@elf.ucw.cz> <43e72e890906191551j1a201a87u4fcccb15ec961762@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <j@w1.fi>,
	Luis Rodriguez <Luis.Rodriguez@atheros.com>,
	Greg KH <greg@kroah.com>, "corbet@lwn.net" <corbet@lwn.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tshibata@ab.jp.nec.com" <tshibata@ab.jp.nec.com>
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:33111 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbZFUGaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2009 02:30:02 -0400
Content-Disposition: inline
In-Reply-To: <43e72e890906191551j1a201a87u4fcccb15ec961762@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Non-intrusive bugfixes _are_ welcome after -rc1.
> 
> That's great news to me.
> 
> I think it would really help to get a clarification on what is meant
> by "non-intrusive bugfixes" though. Can you elaborate on that?

Typo fix in printk() is non-intrusive, 'apply this series' is
borderline; if issue is bad enough it may be ok. I guess only Linus
can clarify more.

> >> > Non-intrusive bugfixes too, afaict.
> >>
> >> It really depends on what you mean but generally no, and this is why I
> >> think this clarification is important.
> >
> > I believe you are wrong.
> 
> I was actually hoping I would be. But I'd like some confirmation that I am.
> 
> For example, based on your feedback we have a series of fixes we'd
> like to try to get merged for 2.6.31-rc2 for ath9k. I have been under
> the impression that since those fixes do not meet the criteria
> clarified by my original patch on documentation for the rc-series that
> they would not get merged and our only option to get users to get
> these patches is to wait for 2.6.32 or use some sort of bleeding edge
> backport package. We try hard to get out our patches in time prior

I believe 'no git merges after rc1' is one of rules.
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
