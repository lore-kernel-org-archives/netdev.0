From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] sctp: Implement socket option
 SCTP_GET_ASSOC_NUMBER
Date: Thu, 25 Dec 2008 16:57:43 -0800 (PST)
Message-ID: <20081225.165743.227309090.davem@davemloft.net>
References: <1229737672-28328-1-git-send-email-vladislav.yasevich@hp.com>
	<1229737672-28328-5-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	yjwei@cn.fujitsu.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58144
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752234AbYLZA5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 19:57:40 -0500
In-Reply-To: <1229737672-28328-5-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 19 Dec 2008 20:47:50 -0500

> From: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> Implement socket option SCTP_GET_ASSOC_NUMBER of the latest ietf socket
> extensions API draft.
> 
>   8.2.5.  Get the Current Number of Associations (SCTP_GET_ASSOC_NUMBER)
> 
>    This option gets the current number of associations that are attached
>    to a one-to-many style socket.  The option value is an uint32_t.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
