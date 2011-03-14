From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Sun, 13 Mar 2011 23:18:32 -0700 (PDT)
Message-ID: <20110313.231832.226787024.davem@davemloft.net>
References: <20110314163135.f366742e.sfr@canb.auug.org.au>
	<20110313.225312.193696949.davem@davemloft.net>
	<20110314170546.af552b4e.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com,
	peterz@infradead.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110314170546.af552b4e.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 14 Mar 2011 17:05:46 +1100

> On Sun, 13 Mar 2011 22:53:12 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
>>
>> From: Stephen Rothwell <sfr@canb.auug.org.au>
>> Date: Mon, 14 Mar 2011 16:31:35 +1100
>> 
>> > Maybe some config option changed ...
>> 
>> Perhaps GENERIC_HARDIRQS_NO_DEPRECATED?
> 
> Yep, that has been turned on for powerpc now.  I guess you will have the
> same problem on sparc64 of you merge the net-next and sparc trees ...

I've done this as recently as last night, and for some reason I have no
build problems.
