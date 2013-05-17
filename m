From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Resend 2/2] net/usb: r8152: Use module_usb_driver()
Date: Fri, 17 May 2013 14:19:18 -0700 (PDT)
Message-ID: <20130517.141918.880057220848367084.davem@davemloft.net>
References: <1368762488-22017-1-git-send-email-sachin.kamat@linaro.org>
	<1368762488-22017-2-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org, hayeswang@realtek.com,
	nic_swsd@realtek.com
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756625Ab3EQVTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 17:19:25 -0400
In-Reply-To: <1368762488-22017-2-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Fri, 17 May 2013 09:18:08 +0530

> module_usb_driver() eliminates boilerplate and simplifies the code.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied.
