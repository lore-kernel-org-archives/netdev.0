From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v5] IPv6: add the option to use anycast addresses as source addresses in echo reply
Date: Wed, 8 Jan 2014 01:56:50 -0800 (PST)
Message-ID: <1389175010.88819.YahooMailBasic@web125502.mail.ne1.yahoo.com>
References: <20140107231737.GM30393@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: Bill Fink <billfink@mindspring.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm35.bullet.mail.ne1.yahoo.com ([98.138.229.28]:35015 "HELO
	nm35.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755054AbaAHJ7s convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 04:59:48 -0500
In-Reply-To: <20140107231737.GM30393@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1/7/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> I forgot to mention, rest of kernel followes the old RFC
> advise to never
> use anycast addresses as source addresses.
 
> I guess this will be weakend with upcoming patches so in
> future this
> depends on socket settings and other tweaks. If that's the
> case default will
> be to also respond with anycast source if original
> destination was anycast.
 
The next patch will address the datagrams case.

BR
Francois-Xavier
