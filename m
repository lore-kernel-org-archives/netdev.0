From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH] IPv6: add option to use Subnet-Router anycast addresses as source addresses
Date: Thu, 2 Jan 2014 07:34:29 -0800 (PST)
Message-ID: <1388676869.77003.YahooMailBasic@web125501.mail.ne1.yahoo.com>
References: <52C582D1.8040107@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm44.bullet.mail.ne1.yahoo.com ([98.138.120.51]:27020 "HELO
	nm44.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750814AbaABPel convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 10:34:41 -0500
In-Reply-To: <52C582D1.8040107@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--------------------------------------------
On Thu, 1/2/14, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:

> Hello.
 
Hello,

>> +					!(net->ipv6.enable_anycast_src &&
>> +					  ipv6_chk_acast_addr(net, NULL,
>> +						&src_info->ipi6_addr)) &&

>   The continuation line should start right under 'net' on the previous line.

> WBR, Sergei 

Thanks,

I will make the change in patch version 2.

BR, Francois-Xavier
