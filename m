From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: getting warn once around skb_try_coalesce
Date: Tue, 10 Jul 2012 15:19:36 +0300
Message-ID: <4FFC1DD8.80103@mellanox.com>
References: <4FFBFBD2.6030004@mellanox.com>  <1341915510.3265.4734.camel@edumazet-glaptop>  <1341918848.3265.4853.camel@edumazet-glaptop> <1341919328.3265.4871.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shlomo Pongratz <shlomop@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:36681 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755376Ab2GJMTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 08:19:41 -0400
In-Reply-To: <1341919328.3265.4871.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/10/2012 2:22 PM, Eric Dumazet wrote:
> And of course we also can fix the truesize bug. (Not sure it will fix 
> the warning, but worth trying) 



thanks, we will give that a try and let you know
