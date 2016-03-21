From: Luis de Bethencourt <luisbg@osg.samsung.com>
Subject: Re: [PATCH] ipv6: remove unused in6_addr struct
Date: Mon, 21 Mar 2016 19:19:39 +0000
Message-ID: <56F0494B.4080501@osg.samsung.com>
References: <1458581848-844-1-git-send-email-luisbg@osg.samsung.com> <20160321.141327.1149650430866826875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	javier@osg.samsung.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:55314 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757817AbcCUTTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2016 15:19:48 -0400
In-Reply-To: <20160321.141327.1149650430866826875.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/03/16 18:13, David Miller wrote:
> From: Luis de Bethencourt <luisbg@osg.samsung.com>
> Date: Mon, 21 Mar 2016 17:37:28 +0000
> 
>> struct in6_addr isn't used anymore in inet6_connection_sock.h, removing
>> the forward declaration.
>>
>> Fixes: 1b33bc3e9e90 ("ipv6: remove obsolete inet6 functions")
>> Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
> 
> Applied, thank you.
> 

Thank you for all the recent reviews David :)

Luis
