From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [PATCH 00/16] sleep_on removal, second try
Date: Fri, 28 Feb 2014 09:53:37 +0100
Message-ID: <53104E91.6070109@linux-pingi.de>
References: <1393412516-3762435-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Jens Axboe <axboe@kernel.dk>,
	Karsten Keil <isdn@linux-pingi.de>,
	Mauro Carvalho Chehab <m.chehab@samsung.com>,
	Michael Schmitz <schmitz@biophys.uni-duesseldorf.de>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-atm-general@lists.sourceforge.net,
	linux-media@vger.kernel.org, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393412516-3762435-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 26.02.2014 12:01, schrieb Arnd Bergmann:
> It's been a while since the first submission of these patches,
> but a lot of them have made it into linux-next already, so here
> is the stuff that is not merged yet, hopefully addressing all
> the comments.
> 
> Geert and Michael: the I was expecting the ataflop and atari_scsi
> patches to be merged already, based on earlier discussion.
> Can you apply them to the linux-m68k tree, or do you prefer
> them to go through the scsi and block maintainers?
> 
> Jens: I did not get any comments for the DAC960 and swim3 patches,
> I assume they are good to go in. Please merge.
> 
> Hans and Mauro: As I commented on the old thread, I thought the
> four media patches were on their way. I have addressed the one
> comment that I missed earlier now, and used Hans' version for
> the two patches he changed. Please merge or let me know the status
> if you have already put them in some tree, but not yet into linux-next
> 
> Greg or Andrew: The parport subsystem is orphaned unfortunately,
> can one of you pick up that patch?
> 
> Davem: The two ATM patches got acks, but I did not hear back from
> Karsten regarding the ISDN patches. Can you pick up all six, or
> should we wait for comments about the ISDN patches?
>


Ack on the ISDN stuff (12,13,14,15)
