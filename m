From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] cxgb3: Use CAP_SYS_RAWIO for firmware
Date: Tue, 06 May 2008 12:28:38 -0400
Message-ID: <48208736.1050806@garzik.org>
References: <20080429142930.0181f078@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60911 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753730AbYEFQ2k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 12:28:40 -0400
In-Reply-To: <20080429142930.0181f078@core>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Cox wrote:
> Otherwise theoretically at least
> 
> 	CAP_NET_ADMIN
> 	Reload new firmware
> 	Wait..
> 	Firmware patches kernel
> 
> So it should be CAY_SYS_RAWIO - not that I suspect this is in fact a
> credible attack vector!
> 
> Signed-off-by: Alan Cox <alan@redhat.com>

applied


