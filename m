From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH net-next] net: sock_diag_handler structs can be const
Date: Wed, 25 Apr 2012 16:29:05 +0400
Message-ID: <4F97EE11.2090408@parallels.com>
References: <4F977BB3.5040201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	davidshan <davidshan@tencent.com>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:13012 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752995Ab2DYM3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 08:29:30 -0400
In-Reply-To: <4F977BB3.5040201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2012 08:21 AM, Shan Wei wrote:
> From: Shan Wei <davidshan@tencent.com>
> 
> read only, so change it to const.
> 
> Signed-off-by: Shan Wei <davidshan@tencent.com>

Acked-by: Pavel Emelyanov <xemul@parallels.com>
