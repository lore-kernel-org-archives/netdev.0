From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: via/Kconfig: replace USE_OF with OF_???
Date: Sun, 21 Jun 2015 10:05:38 -0700 (PDT)
Message-ID: <20150621.100538.84744540201242069.davem@davemloft.net>
References: <1434541351-9699-1-git-send-email-borneo.antonio@gmail.com>
	<1434541351-9699-3-git-send-email-borneo.antonio@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, daniel.lezcano@linaro.org,
	tglx@linutronix.de
To: borneo.antonio@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbbFUQxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 12:53:52 -0400
In-Reply-To: <1434541351-9699-3-git-send-email-borneo.antonio@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Borneo <borneo.antonio@gmail.com>
Date: Wed, 17 Jun 2015 19:42:31 +0800

> USE_OF is used as intermediate Kconfig option by few
> arch's (ARM, MIPS, Xtensa).
> Replace instances of USE_OF outside of arch folders
> with proper OF_???.
> 
> Signed-off-by: Antonio Borneo <borneo.antonio@gmail.com>

Applied to net-next, thanks.
