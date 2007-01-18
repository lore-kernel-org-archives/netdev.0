From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] myri10ge: make wc_fifo usage load-time tunable
Date: Thu, 18 Jan 2007 12:02:50 -0500
Message-ID: <45AFA83A.5040107@garzik.org>
References: <45A3F4FF.5000803@myri.com> <45A3F549.4070404@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44493 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072AbXARRCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 12:02:52 -0500
To: Brice Goglin <brice@myri.com>
In-Reply-To: <45A3F549.4070404@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Under some circumstances, using WC without the WC fifo is faster.
> So we make it possible to tune wc_fifo with a module parameter.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)

applied 1-3


