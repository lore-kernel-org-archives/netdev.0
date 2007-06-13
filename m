From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] add return value check of request_irq()
Date: Wed, 13 Jun 2007 15:55:05 -0400
Message-ID: <46704B99.3090908@garzik.org>
References: <20070605225506.72e5f8fe.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39057 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752499AbXFMTzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 15:55:09 -0400
In-Reply-To: <20070605225506.72e5f8fe.yoichi_yuasa@tripeaks.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yoichi Yuasa wrote:
> Hi,
> 
> This patch has added return value check of request_irq() to pcmcia net drivers.
> 
> Yoichi
> 
> Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>

applied to #upstream (2.6.23)


