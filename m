From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] sctp: Add validity check for
 SCTP_PARTIAL_DELIVERY_POINT socket option
Date: Thu, 25 Dec 2008 16:59:14 -0800 (PST)
Message-ID: <20081225.165914.95302523.davem@davemloft.net>
References: <1229737672-28328-1-git-send-email-vladislav.yasevich@hp.com>
	<1229737672-28328-7-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	yjwei@cn.fujitsu.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58153
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752234AbYLZA7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 19:59:11 -0500
In-Reply-To: <1229737672-28328-7-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 19 Dec 2008 20:47:52 -0500

> The latest ietf socket extensions API draft said:
> 
>   8.1.21.  Set or Get the SCTP Partial Delivery Point
> 
>     Note also that the call will fail if the user attempts to set
>     this value larger than the socket receive buffer size.
> 
> This patch add this validity check for SCTP_PARTIAL_DELIVERY_POINT
> socket option.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Also applied, thanks.
