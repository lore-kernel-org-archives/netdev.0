From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH/RFC] add netpoll support for gianfar
Date: Tue, 07 Nov 2006 04:30:26 -0500
Message-ID: <45505232.8070806@pobox.com>
References: <20061106141958.00002c6c.vwool@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42163 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1754141AbWKGJa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 04:30:29 -0500
To: Vitaly Wool <vwool@ru.mvista.com>
In-Reply-To: <20061106141958.00002c6c.vwool@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vitaly Wool wrote:
> The patch inlined below adds NET_POLL_CONTROLLER support for gianfar network driver.

As noted, this patch is out of date.  2.6.19-rc kernels removed the 
pt_regs argument from all irq handlers.

	Jeff



