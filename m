From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH 1/5] [IPV6]: Remove ndiscs rt6_lock dependency
Date: Mon, 31 Jul 2006 14:01:41 +0300
Message-ID: <44CDE315.5020104@tcs.hut.fi>
References: <20060726221100.325687073@postel.suug.ch>	<20060726221849.188750063@postel.suug.ch> <20060726.152845.71540437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:44041 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S932190AbWGaLBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 07:01:42 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060726.152845.71540437.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Thu, 27 Jul 2006 00:00:01 +0200
> 
>> (Ab)using rt6_lock wouldn't work anymore if rt6_lock is
>> converted into a per table lock.
>>
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> This one looks great.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Ditto.
Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>

> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

