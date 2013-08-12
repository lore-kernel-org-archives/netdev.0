From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: Add MOXA ART SoCs ethernet driver
Date: Sun, 11 Aug 2013 21:38:46 -0700 (PDT)
Message-ID: <20130811.213846.2022624715665927428.davem@davemloft.net>
References: <1375349968-16059-1-git-send-email-jonas.jensen@gmail.com>
	<1375961694-5375-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, arm@kernel.org, florian@openwrt.org,
	joe@perches.com, mark.rutland@arm.com
To: jonas.jensen@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375961694-5375-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jonas Jensen <jonas.jensen@gmail.com>
Date: Thu,  8 Aug 2013 13:34:54 +0200

> The MOXA UC-711X hardware(s) has an ethernet controller that seem
> to be developed internally. The IC used is "RTL8201CP".
> 
> Since there is no public documentation, this driver is mostly the
> one published by MOXA that has been heavily cleaned up / ported
> from linux 2.6.9.
> 
> Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>

Applied to net-next, thanks.
