From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 1/2] netpoll: Convert printks to np_<level> and
 add pr_fmt
Date: Mon, 30 Jan 2012 11:13:51 +0800
Message-ID: <4F260AEF.9020900@gmail.com>
References: <8a61df72a4eb6caaeaa8b5be644be227da61512b.1327888082.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62512 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240Ab2A3DOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2012 22:14:04 -0500
In-Reply-To: <8a61df72a4eb6caaeaa8b5be644be227da61512b.1327888082.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/30/2012 09:50 AM, Joe Perches wrote:
> Use a more current message logging style.
> Add pr_fmt to prefix dmesg output with "netpoll: "
> Add macros to print np->name.
>
> Signed-off-by: Joe Perches<joe@perches.com>

Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>

Thanks.
