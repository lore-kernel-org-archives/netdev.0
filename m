From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Resend 1/2] net/usb: r8152: Remove redundant version.h
 header inclusion
Date: Fri, 17 May 2013 14:19:13 -0700 (PDT)
Message-ID: <20130517.141913.1853486856630872773.davem@davemloft.net>
References: <1368762488-22017-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org, hayeswang@realtek.com
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756246Ab3EQVTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 17:19:14 -0400
In-Reply-To: <1368762488-22017-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Fri, 17 May 2013 09:18:07 +0530

> version.h header inclusion is not necessary as detected by
> checkversion.pl.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied.
