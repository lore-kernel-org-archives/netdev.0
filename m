From: Don Fry <pcnet32@frontier.com>
Subject: Re: [PATCH 04/52] net: pcnet32: remove unnecessary
 pci_set_drvdata()
Date: Mon, 16 Sep 2013 20:14:48 -0700
Message-ID: <1379387688.17190.1.camel@Linux>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
	 <004e01ceaec0$0b8ee0f0$22aca2d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from filter01.dlls.pa.frontiernet.net ([199.224.80.228]:40792 "EHLO
	filter01.dlls.pa.frontiernet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751749Ab3IQDVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 23:21:40 -0400
In-Reply-To: <004e01ceaec0$0b8ee0f0$22aca2d0$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Date: Wed, 11 Sep 2013 16:25:09 +0900
> 
> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Acked-by: Don Fry <pcnet32@frontier.com>
 
