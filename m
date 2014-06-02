From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: tunnels - enable module autoloading
Date: Mon, 02 Jun 2014 13:40:37 -0700 (PDT)
Message-ID: <20140602.134037.340629330868591957.davem@davemloft.net>
References: <1400188890-2038-1-git-send-email-teg@jklm.no>
	<20140521.154744.124910385161203311.davem@davemloft.net>
	<CAG-2HqUEqz26YMTDHNVHUEtWDcaVrq3EKX-e8-9wnm4Y1XCUag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	kuznet@ms2.inr.ac.ru
To: teg@jklm.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG-2HqUEqz26YMTDHNVHUEtWDcaVrq3EKX-e8-9wnm4Y1XCUag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Gundersen <teg@jklm.no>
Date: Mon, 2 Jun 2014 20:57:02 +0200

> Would this patch be suitable for stable? While it does not fix a
> regression, it appears to fix the intended behaviour of
> MODULE_ALIAS_RTNL_LINK?

It probably is suitable... I'll queue it up, thanks.
