From: Bryan Lawver <lawver1@llnl.gov>
Subject: Re: [ofa-general] Re: IPoIB forwarding
Date: Thu, 03 May 2007 16:37:46 -0700
Message-ID: <6.1.2.0.2.20070503163428.15b51750@mail.llnl.gov>
References: <6.1.2.0.2.20070423160212.12db6400@mail.llnl.gov>
 <20070425124652.GG1624@mellanox.co.il>
 <6.1.2.0.2.20070426083410.1389d9e0@mail.llnl.gov>
 <20070426161409.GF15540@mellanox.co.il>
 <6.1.2.0.2.20070426095112.138e9a68@mail.llnl.gov>
 <20070426180618.GJ15540@mellanox.co.il>
 <6.1.2.0.2.20070427115435.13ea5ec0@mail.llnl.gov>
 <46325DF3.2050203@hp.com>
 <6.1.2.0.2.20070427152027.13fe46d0@mail.llnl.gov>
 <46327A07.1000404@hp.com>
 <6.1.2.0.2.20070427153952.13fc7d08@mail.llnl.gov>
 <4632894D.40705@hp.com>
 <20070428025117.a3b1200a.billfink@mindspring.com>
 <4634F49F.9030408@myri.com>
 <46365BD4.5060607@hp.com>
 <4637B9A4.2050103@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: Bill Fink <billfink@mindspring.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	mst@dev.mellanox.co.il, general@lists.openfabrics.org
To: Loic Prylli <loic@myri.com>, Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nspiron-2.llnl.gov ([128.115.41.82]:36328 "EHLO
	nspiron-2.llnl.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754680AbXECXhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 19:37:47 -0400
In-Reply-To: <4637B9A4.2050103@myri.com>
References: <6.1.2.0.2.20070423160212.12db6400@mail.llnl.gov>
 <20070425124652.GG1624@mellanox.co.il>
 <6.1.2.0.2.20070426083410.1389d9e0@mail.llnl.gov>
 <20070426161409.GF15540@mellanox.co.il>
 <6.1.2.0.2.20070426095112.138e9a68@mail.llnl.gov>
 <20070426180618.GJ15540@mellanox.co.il>
 <6.1.2.0.2.20070427115435.13ea5ec0@mail.llnl.gov>
 <46325DF3.2050203@hp.com>
 <6.1.2.0.2.20070427152027.13fe46d0@mail.llnl.gov>
 <46327A07.1000404@hp.com>
 <6.1.2.0.2.20070427153952.13fc7d08@mail.llnl.gov>
 <4632894D.40705@hp.com>
 <20070428025117.a3b1200a.billfink@mindspring.com>
 <4634F49F.9030408@myri.com>
 <46365BD4.5060607@hp.com>
 <4637B9A4.2050103@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have been able to install and use the 1.3.0 myricom driver and everything 
works as I expected and performance is pretty decent.  Interesting little 
side tour through various drivers...The router node sees almost no load 
which is really encouraging.

Thanks,
bryan

At 03:05 PM 5/1/2007, Loic Prylli wrote:
>On 4/30/2007 2:12 PM, Rick Jones wrote:
>>
>>Speaking of defaults, it would seem that the external 1.2.0 driver comes 
>>with 9000 bytes as the default MTU?  At least I think that is what I am 
>>seeing now that I've started looking more closely.
>>
>>rick jones
>
>
>That's the same for the in-kernel-tree code (9K MTU by default). Assuming 
>this is not wanted, I will submit a patch for that.
>
>
>Loic

