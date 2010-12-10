From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] New jhash function
Date: Thu, 09 Dec 2010 20:19:26 -0800 (PST)
Message-ID: <20101209.201926.104055585.davem@davemloft.net>
References: <1291379941-31565-1-git-send-email-kadlec@blackhole.kfki.hu>
	<20101208.090954.115924303.davem@davemloft.net>
	<201012090753.46050.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kadlec@blackhole.kfki.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	torvalds@osdl.org
To: rusty@rustcorp.com.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201012090753.46050.rusty@rustcorp.com.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 9 Dec 2010 07:53:45 +1030

> On Thu, 9 Dec 2010 03:39:54 am David Miller wrote:
>> From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
>> Date: Fri,  3 Dec 2010 13:38:59 +0100
>> 
>> > The current jhash.h implements the lookup2() hash function by Bob Jenkins. 
>> > However, lookup2() is outdated as Bob wrote a new hash function called 
>> > lookup3(). There is a longer comparison of those two and other hash
>> > functions at http://burtleburtle.net/bob/hash/doobs.html.
>> > 
>> > Please consider applying the following patches.
>> 
>> Patch #1 is already in the net-next-2.6 tree, and as long as there are
>> no major objections to the general crowd (including Rusty et al.) I am
>> happy to put patch #2 into my tree as well.
>> 
>> Rusty, does the current version of patch #2 look good to you?
> 
> Yes, 2/2 good.  Thanks Jozsef!
> 
> Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Applied, thanks everyone.
