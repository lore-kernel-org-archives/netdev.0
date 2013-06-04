From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2013-06-03
Date: Tue, 04 Jun 2013 14:31:04 -0700 (PDT)
Message-ID: <20130604.143104.2025566832254132168.davem@davemloft.net>
References: <1370261733-22935-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935Ab3FDVbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 17:31:05 -0400
In-Reply-To: <1370261733-22935-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon,  3 Jun 2013 14:15:30 +0200

> here are there fixes for the v3.10 release cycle:
> 
> The first patch by Jonas Peterson and Olivier Sobrie fixes the reception of CAN
> frames on Kvaser's "USBcan Pro" and "USBcan R" type hardware.
> 
> The last two patches by Olivier Sobrie (for esd_usb2) and me (for peak_usb)
> change the memory handling for the USB messages from stack to kmalloc(), as
> memory used for DMA should not be allocated on stack.
 ...
>   git://gitorious.org/linux-can/linux-can.git fixes-for-3.10

Pulled, thanks Marc.
