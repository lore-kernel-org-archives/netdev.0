From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC] Documentation: add documentation for rc-series and merge
 window
Date: Fri, 19 Jun 2009 15:56:25 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0906191555390.16802@localhost.localdomain>
References: <20090615214735.GE23972@bombadil.infradead.org> <20090615223206.GA4966@kroah.com> <20090616004122.GC5492@tesla> <20090616021011.GF23972@bombadil.infradead.org> <20090616032034.GA17932@kroah.com> <20090616042113.GA5680@tesla> <20090616093401.GA11602@jm.kir.nu>
 <20090616181705.GB31506@tesla> <20090619150015.GC1389@ucw.cz> <43e72e890906191010v4b2e79a5x2c7b722b8209933c@mail.gmail.com> <20090619221909.GC2229@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jouni Malinen <j@w1.fi>,
	Luis Rodriguez <Luis.Rodriguez@atheros.com>,
	Greg KH <greg@kroah.com>, "corbet@lwn.net" <corbet@lwn.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tshibata@ab.jp.nec.com" <tshibata@ab.jp.nec.com>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55205 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752123AbZFSW5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 18:57:08 -0400
In-Reply-To: <20090619221909.GC2229@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 20 Jun 2009, Pavel Machek wrote:
> 
> Non-intrusive bugfixes _are_ welcome after -rc1.

After -rc1, yes.

After something like -rc5? No.

They had better be _really_ important things, and _really_ obvious and 
non-intrusive.  Not just "any bug".

		Linus
