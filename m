From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v2] IPv6: add option to use Subnet-Router anycast addresses as source addresses
Date: Fri, 3 Jan 2014 01:38:34 -0800 (PST)
Message-ID: <1388741914.4774.YahooMailBasic@web125501.mail.ne1.yahoo.com>
References: <20140103070909.GM22494@order.stressinduktion.org>
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
Received: from nm6-vm1.bullet.mail.ne1.yahoo.com ([98.138.91.71]:27058 "HELO
	nm6-vm1.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751014AbaACJoR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 04:44:17 -0500
In-Reply-To: <20140103070909.GM22494@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--------------------------------------------
On Fri, 1/3/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> And actually, my preferred setup would be to use anycast
> addresses as source
> addresses, but still have ping use the unicast address. This
> current patch
> does not allow that?
 
No, I will send separate patches for echo reply and datagrams.

Francois-Xavier 
 
