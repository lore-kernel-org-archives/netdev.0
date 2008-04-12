From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] spidernet: add missing initialization
Date: Sat, 12 Apr 2008 05:01:05 -0400
Message-ID: <48007A51.5020300@pobox.com>
References: <20080411.122734.-1300523219.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jens@de.ibm.com, netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59339 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757628AbYDLJBV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:01:21 -0400
In-Reply-To: <20080411.122734.-1300523219.kouish@swc.toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ishizaki Kou wrote:
> This patch fixes initialization of "aneg_count" and "medium" fields in
> spider_net_card to make spidernet driver correctly sets "link status".
> 
> Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
> Acked-by: Jens Osterkamp <jens@de.ibm.com>
> ---
> 
> Jeff-san,
> 
> Could you consider these spidernet patches for 2.6.26?
> 
> Best regards,
> Kou Ishizaki

applied 1-5


