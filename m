From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ks8851: Use module_spi_driver
Date: Mon, 08 Apr 2013 16:56:29 -0400 (EDT)
Message-ID: <20130408.165629.2099642795714832012.davem@davemloft.net>
References: <1365327184-22956-1-git-send-email-lars@metafoo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben-linux@fluff.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lars@metafoo.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365327184-22956-1-git-send-email-lars@metafoo.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lars-Peter Clausen <lars@metafoo.de>
Date: Sun,  7 Apr 2013 11:33:03 +0200

> By using module_spi_driver we can eliminate a few lines of boilerplate code.
> 
> Signed-off-by: Lars-Peter Clausen <lars@metafoo.de>

Applied.
