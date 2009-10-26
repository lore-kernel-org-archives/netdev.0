From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] PPPoE: Fix flush/close races.
Date: Mon, 26 Oct 2009 16:23:45 -0700 (PDT)
Message-ID: <20091026.162345.237018681.davem@davemloft.net>
References: <e6d1cecd0910261251w721b8258n7dfc1bac9d01af8b@mail.gmail.com>
	<20091026195933.GC5321@lenovo>
	<200910262205.38108.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gorcunov@gmail.com, mostrows@gmail.com, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: denys@visp.net.lb
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <200910262205.38108.denys@visp.net.lb>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Fedoryschenko <denys@visp.net.lb>
Date: Mon, 26 Oct 2009 22:05:37 +0200

> On Monday 26 October 2009 21:59:33 Cyrill Gorcunov wrote:
>> [Michal Ostrowski - Mon, Oct 26, 2009 at 02:51:52PM -0500]
>>
>>
>> Thanks a lot Michal!
>>
>> I think we should add as well
>>
>> Reported-by: Denys Fedoryschenko <denys@visp.net.lb>
>> Tested-by: Denys Fedoryschenko <denys@visp.net.lb>
>>
>> 	-- Cyrill
> 
> Yes, till now everything working perfectly. Confirming :-)

Applied, thanks everyone.
