From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: Remove an unnecessary goto
Date: Mon, 18 Mar 2013 13:07:23 -0400 (EDT)
Message-ID: <20130318.130723.5448740810527224.davem@davemloft.net>
References: <20130318130339.4F76662C03B@msa106.auone-net.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net,
	linux-kernel@vger.kernel.org
To: slash@ac.auone-net.jp
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130318130339.4F76662C03B@msa106.auone-net.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kusanagi Kouichi <slash@ac.auone-net.jp>
Date: Mon, 18 Mar 2013 22:03:39 +0900

> Use else instead.
> 
> Signed-off-by: Kusanagi Kouichi <slash@ac.auone-net.jp>

The code is not in any way more readable with your changes.

I'm not applying this.
