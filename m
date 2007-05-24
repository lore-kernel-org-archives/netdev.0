From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/10] spidernet: beautify error messages
Date: Thu, 24 May 2007 17:27:27 -0400
Message-ID: <4656033F.1060505@garzik.org>
References: <20070522230942.GT5921@austin.ibm.com> <20070522231354.GA2147@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, cbe-oss-dev@ozlabs.org,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Florin Malita <fmalita@gmail.com>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48138 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752676AbXEXV1e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 17:27:34 -0400
In-Reply-To: <20070522231354.GA2147@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> Make error messages print which interface they apply to.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> 
> ----
>  drivers/net/spider_net.c |   10 ++++++----
>  drivers/net/spider_net.h |    2 +-
>  2 files changed, 7 insertions(+), 5 deletions(-)

applied 2-10 to #upstream (2.6.23)


