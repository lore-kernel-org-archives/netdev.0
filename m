From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.8.1 IPv6 Routing Problem
Date: Tue, 21 Sep 2004 19:57:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921195752.015e3d1d.davem@davemloft.net>
References: <20040919074605.GJ6005@sunbeam.de.gnumonks.org>
	<Pine.LNX.4.44.0409200806460.22679-100000@netcore.fi>
	<20040920.152012.114156249.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: pekkas@netcore.fi, laforge@gnumonks.org, netdev@oss.sgi.com,
        usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040920.152012.114156249.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Sep 2004 15:20:12 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> This behavior lives for years (AFAIK),
> and we haven't got so many reports 
> because people usually bring loopback device first.
> 
> I think the following message will help people, anyway.

If ipv6 has a dependency upon this, why doesn't it just
bring the device up itself at this moment if necessary?

It is kind of silly to force this device up ordering
upon people anyways.
