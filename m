From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Add MOXA ART SoCs ethernet driver
Date: Tue, 30 Jul 2013 16:24:34 -0700 (PDT)
Message-ID: <20130730.162434.539163047913568607.davem@davemloft.net>
References: <1374140806-12485-1-git-send-email-jonas.jensen@gmail.com>
	<1374842890-20735-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-doc@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, arm@kernel.org, florian@openwrt.org
To: jonas.jensen@gmail.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1374842890-20735-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jonas Jensen <jonas.jensen@gmail.com>
Date: Fri, 26 Jul 2013 14:48:10 +0200

> +
> +CFLAGS_moxart_ether.o := -DDEBUG

This is not appropriate, please remove this.
