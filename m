From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH/RFC] add netpoll support for gianfar: respin
Date: Tue, 14 Nov 2006 10:24:15 -0500
Message-ID: <4559DF9F.9030607@pobox.com>
References: <20061107132702.11645b80.vwool@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58303 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965932AbWKNPYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 10:24:24 -0500
To: Vitaly Wool <vwool@ru.mvista.com>
In-Reply-To: <20061107132702.11645b80.vwool@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vitaly Wool wrote:
> The patch inlined below adds NET_POLL_CONTROLLER support for gianfar network driver, slightly modified wrt the comments from Andy Fleming.
> 
>  drivers/net/gianfar.c |   33 +++++++++++++++++++++++++++++++++
>  1 file changed, 33 insertions(+)
> 
> Signed-off-by: Vitaly Wool <vwool@ru.mvista.com>

applied


