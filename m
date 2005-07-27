From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.13rc3] IPv6: Check interface bindings on IPv6 raw
 socket reception
Date: Wed, 27 Jul 2005 14:38:01 -0700 (PDT)
Message-ID: <20050727.143801.51840907.davem@davemloft.net>
References: <20050723180442.GB6731@mcdonald.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261159AbVG0V4Q@vger.kernel.org>
To: andrew@mcdonald.org.uk
In-Reply-To: <20050723180442.GB6731@mcdonald.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew McDonald <andrew@mcdonald.org.uk>
Date: Sat, 23 Jul 2005 19:04:43 +0100

> Take account of whether a socket is bound to a particular device when
> selecting an IPv6 raw socket to receive a packet. Also perform this
> check when receiving IPv6 packets with router alert options.
> 
> Signed-off-by: Andrew McDonald <andrew@mcdonald.org.uk>

Applied, thanks Andrew.
