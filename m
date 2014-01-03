From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v2] IPv6: add option to use Subnet-Router anycast addresses as source addresses
Date: Thu, 2 Jan 2014 21:58:56 -0800 (PST)
Message-ID: <1388728736.50849.YahooMailBasic@web125506.mail.ne1.yahoo.com>
References: <20140102231921.GI22494@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm45.bullet.mail.ne1.yahoo.com ([98.138.120.52]:41866 "HELO
	nm45.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750812AbaACGIR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 01:08:17 -0500
In-Reply-To: <20140102231921.GI22494@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------------------------------------
On Thu, 1/2/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
 
> Ah, I guess you are hinting at the situation where you ping
> a pre-defined
> anycast address and expect back a unicast address for
> discovering the unicast
> address of a router e.g.? Ok, I see...
 
Exact
