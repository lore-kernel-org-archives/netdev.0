From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.13rc3] IPv6: Check interface bindings on IPv6 raw
 socket reception
Date: Wed, 27 Jul 2005 14:38:14 -0700 (PDT)
Message-ID: <20050727.143814.93382540.davem@davemloft.net>
References: <20050723180442.GB6731@mcdonald.org.uk>
	<42E2DFAE.8070101@trash.net>
	<42E32980.2090604@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@mcdonald.org.uk, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261169AbVG0WCk@vger.kernel.org>
To: kaber@trash.net
In-Reply-To: <42E32980.2090604@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 24 Jul 2005 07:39:12 +0200

> [IPV4/6]: Check if packet was actually delivered to a raw socket to decide whether to send an ICMP unreachable
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
