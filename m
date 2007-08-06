From: "=?ISO-8859-2?Q?Marcin_=A6lusarz?=" <marcin.slusarz@gmail.com>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Mon, 6 Aug 2007 09:00:44 +0200
Message-ID: <4bacf17f0708060000n5a00bb77i74adc3b4b28ac42b@mail.gmail.com>
References: <alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org>
	 <1185322771.4175.102.camel@chaos>
	 <4bacf17f0707260016x14fc1c92s628ae64353663833@mail.gmail.com>
	 <20070726081326.GA3197@ff.dom.local> <1185437431.3227.21.camel@chaos>
	 <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local>
	 <20070726091254.GA8063@elte.hu>
	 <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com>
	 <20070731132037.GC1046@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Jean-Baptiste Vignaud" <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>
To: "Jarek Poplawski" <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:27247 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292AbXHFHAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 03:00:45 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1688211wah
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2007 00:00:45 -0700 (PDT)
In-Reply-To: <20070731132037.GC1046@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/7/31, Jarek Poplawski <jarkao2@o2.pl>:
> Marcin,
>
> I see you're quite busy, but if after testing this next Ingo's patch
> you are alive yet, maybe you could try one more "idea"? No patch this
> time, but if you could try this after adding boot option "noirqdebug"
> (I'd like to be sure it's not about timinig after all).
It didn't change anything. Network card still timed out.

Marcin
