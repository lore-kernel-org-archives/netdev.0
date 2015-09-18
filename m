From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 0/30] Passing net through the netfilter hooks
Date: Thu, 17 Sep 2015 22:38:46 -0700 (PDT)
Message-ID: <20150917.223846.760880389155481640.davem@davemloft.net>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
	<20150917.171904.119452251415625585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150917.171904.119452251415625585.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 17 Sep 2015 17:19:04 -0700 (PDT)

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 15 Sep 2015 19:59:49 -0500
> 
>> Pablo, Dave I don't know whose tree this makes more sense to go
>> through.  I am assuming at least initially Pablos as netfilter is
>> involved.  From what I have seen there will be a lot of back and forth
>> between the netfilter code paths and the routing code paths.
> 
> I think it might reduce conflicts actually if it went via my net-next
> tree.
> 
> Pablo, any objections?

I actually decided to just push it out to my tree, if there are any
problems with that I will revert.

Thanks.
