From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 0/3] ser_gigaset fixes
Date: Sat, 12 Dec 2015 19:32:12 +0100
Message-ID: <1449945132.2402.16.camel@tiscali.nl>
References: <cover.1449570042.git.tilman@imap.cc>
	 <1449747069.16068.27.camel@tiscali.nl> <566C62E8.4010308@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller@googlegroups.com, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	gigaset307x-common@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud2.xs4all.net ([194.109.24.25]:48717 "EHLO
	lb2-smtp-cloud2.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751668AbbLLScR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 13:32:17 -0500
In-Reply-To: <566C62E8.4010308@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tilman,

On za, 2015-12-12 at 19:09 +0100, Tilman Schmidt wrote:
> Am 10.12.2015 um 12:31 schrieb Paul Bolle:
> > 1/3 ran into objections and, I think, Alan Cox is working on an
> > alternative for it. Would you mind resending 2/3 and 3/3 as a two
> > patches series? Feel free to add
> >     Acked-by: Paul Bolle <pebolle@tiscali.nl>
> > 
> > to both.
> 
> Alan's patch dated 09 Dec 2015 20:33:24 applies on top of 1/3 so I
> reckon it should be kept.

Which apparently never hit my INBOX. If it had, we wouldn't have been
discussing my request to resend. Thanks for pointing me at that patch!

> > (The previous gigaset series, which you sent in July this year, was
> > picked up from netdev directly by David Miller. Unless people
> > actually
> > prefer these patches to also be signed-off by me, I'm perfectly fine
> > with that.)
> 
> I think as a maintainer you are supposed to sign off patches for the
> code you maintain. My signed-off as recently retired ex-maintainer was
> probably still good enough in July. I'm unsure whether it still is 
> today.

So I'll jot you down as someone preferring that I sign off.

I'll take your series, and Alan's patch - which you just forwarded to me
in a separate message - and kick them around a bit more. Then I expect
to send everything to netdev by next Monday.

Thanks,


Paul Bolle
