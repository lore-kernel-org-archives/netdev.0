From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/10] ps3: fix wrong calculation of rx descriptor address
Date: Tue, 24 Jul 2007 16:36:46 -0400
Message-ID: <46A662DE.4020304@garzik.org>
References: <20070720172015.6787.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58979 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757745AbXGXUgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 16:36:50 -0400
In-Reply-To: <20070720172015.6787.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Masakazu Mokuno wrote:
> Fixed the bug that calculation of the address of rx descriptor was
> wrong.
> 
> Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
> ---
>  drivers/net/ps3_gelic_net.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

applied 1-10


