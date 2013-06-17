From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2013-06-17
Date: Mon, 17 Jun 2013 16:19:01 -0700 (PDT)
Message-ID: <20130617.161901.1229542193546651097.davem@davemloft.net>
References: <20130617182719.GC2104@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130617182719.GC2104@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 17 Jun 2013 14:27:20 -0400

> This will probably be the last batch of wireless fixes intended
> for 3.10.  Many of these are one- or two-liners, and a couple of
> others are mostly relocating existing code to avoid races or to
> limit the code to effecting specific hardware, etc.

This looks fine even though the HT info fix is a bit sizable.

Pulled, thanks a lot.
