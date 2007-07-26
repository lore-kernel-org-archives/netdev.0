From: "=?ISO-8859-2?Q?Marcin_=A6lusarz?=" <marcin.slusarz@gmail.com>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Thu, 26 Jul 2007 09:16:10 +0200
Message-ID: <4bacf17f0707260016x14fc1c92s628ae64353663833@mail.gmail.com>
References: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com>
	 <20070629150759.GC2771@ff.dom.local>
	 <4bacf17f0707222244p664e7a6ap850b3357a57d73c@mail.gmail.com>
	 <20070724080534.GC18740@elte.hu> <20070724094202.GA11610@elte.hu>
	 <alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org>
	 <20070724200431.GA22190@elte.hu> <1185322771.4175.102.camel@chaos>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "Thomas Gleixner" <tglx@linutronix.de>,
	"Ingo Molnar" <mingo@elte.hu>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Jarek Poplawski" <jarkao2@o2.pl>,
	"Jean-Baptiste Vignaud" <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <1185322771.4175.102.camel@chaos>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/7/25, Thomas Gleixner <tglx@linutronix.de>:
> (...)

I've tested Jarek's patch, 2 Ingo's patches (2nd and 3rd) and Thomas'
patch (one patch at time of course) - all of them fixed the problem,
but the last one flooded my logs with "Skip resend for irq 17". All
tests were done on 2.6.21.3.

I wanted to test them all on 2.6.22.1, but I didn't have enough time.
I've verified only that 2.6.22.1 has the same problem. I can test it
later, but I can report results back at beginning of next week.

Regards,
Marcin Slusarz
