From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-10-07
Date: Fri, 08 Oct 2010 10:38:42 -0700 (PDT)
Message-ID: <20101008.103842.39184623.davem@davemloft.net>
References: <20101007185859.GD20950@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101007185859.GD20950@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 7 Oct 2010 14:58:59 -0400

> Here are a few more more-or-less-one-liner fixes intended for 2.6.36.
> The one from Felix fixes a regression introduced in the 2.6.36 cycle.
> The one from Johannes fixes a crash reported by Ben Greear (as
> documented in the changelog).  The one from me reverts and earlier patch
> from me that can result in stuff in dmesg from not calling
> netif_receive_skb in the proper context.

Pulled, thanks John.
