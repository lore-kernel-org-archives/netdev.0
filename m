From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 2/7] Blackfin: on-chip ethernet MAC controller driver
Date: Tue, 10 Jul 2007 12:47:59 -0400
Message-ID: <4693B83F.8080104@garzik.org>
References: <200707091850.l69IoK5v001679@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bryan.wu@analog.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60285 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754489AbXGJQsB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:48:01 -0400
In-Reply-To: <200707091850.l69IoK5v001679@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: "Wu, Bryan" <bryan.wu@analog.com>
> 
> This patch implements the driver necessary use the Analog Devices
> Blackfin processor's on-chip ethernet MAC controller.
> 
> Signed-off-by: Bryan Wu <bryan.wu@analog.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/Kconfig    |   44 +
>  drivers/net/Makefile   |    1 
>  drivers/net/bfin_mac.c |  981 +++++++++++++++++++++++++++++++++++++++
>  drivers/net/bfin_mac.h |  147 +++++
>  4 files changed, 1173 insertions(+)

If I'm not mistaken, Bryan just said he was resending an updated version?


