From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ucc_geth: kmalloc casting cleanups
Date: Tue, 09 Jan 2007 02:15:56 -0500
Message-ID: <45A3412C.2050008@garzik.org>
References: <45A3105B.7090302@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60466 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751127AbXAIHP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 02:15:59 -0500
To: Li Yang <leoli@freescale.com>
In-Reply-To: <45A3105B.7090302@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Li Yang wrote:
> From: Ahmed S. Darwish <darwish.07@gmail.com>
> 
> Switch kmalloc to kzalloc and clean some redundant kmalloc
> casts.
> 
> Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---


I should wait for Kumar to resend ucc_geth fixes before applying this, 
right?

	Jeff


