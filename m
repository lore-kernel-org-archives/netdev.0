From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next 0/3] Add new capability and macb DT variant
Date: Thu, 07 Jan 2016 16:26:55 -0500 (EST)
Message-ID: <20160107.162655.1622191748939046737.davem@davemloft.net>
References: <1451900573-22657-1-git-send-email-narmstrong@baylibre.com>
	<1452001158-20585-1-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, harini.katakam@xilinx.com,
	boris.brezillon@free-electrons.com,
	alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, joshc@ni.com, devicetree@vger.kernel.org
To: narmstrong@baylibre.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452001158-20585-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Armstrong <narmstrong@baylibre.com>
Date: Tue,  5 Jan 2016 14:39:15 +0100

> The first patch introduces a new capability bit to disable usage of the
> USRIO register on platform not implementing it thus avoiding some external
> imprecise aborts on ARM based platforms.
> The two last patchs adds a new macb variant compatible name using the
> capability, the NP4 SoC uses this particular hardware configuration.
> 
> v1: http://lkml.kernel.org/r/1449485914-12883-1-git-send-email-narmstrong@baylibre.com
> v2: http://lkml.kernel.org/r/1449582726-6148-1-git-send-email-narmstrong@baylibre.com
> v3: http://lkml.kernel.org/r/1451898103-21868-1-git-send-email-narmstrong@baylibre.com
> v4: http://lkml.kernel.org/r/1451900573-22657-1-git-send-email-narmstrong@baylibre.com
> v5: switch SoC name to non-generic NP4 name

Series applied to net-next, thanks.
