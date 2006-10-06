From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 01/02] net/ipv6: seperate sit driver to extra module
Date: Fri, 06 Oct 2006 21:59:35 +0900 (JST)
Message-ID: <20061006.215935.92667295.yoshfuji@linux-ipv6.org>
References: <20061006093402.GA12460@zlug.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48143 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751353AbWJFM5L
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 08:57:11 -0400
To: joro-lkml@zlug.org
In-Reply-To: <20061006093402.GA12460@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20061006093402.GA12460@zlug.org> (at Fri, 6 Oct 2006 11:34:02 +0200), Joerg Roedel <joro-lkml@zlug.org> says:

> this is the submit of the patch discussed yesterday to compile the sit
> driver as a seperate module.
> 
> changes to yesterday:
> - default select changed to y in Kconfig
> - added ifdefs to net/ipv6/addrconf.c
>   (this part is big, to keep the patches around 100 lines the
>    addrconf.c changes are posted in a seperate patch)
> 
> Signed-off-by: Joerg Roedel <joro-lkml@zlug.org>

> +         into IPv4 packets. This is usefull if you want to connect two IPv6
                                       ~~~~~~~useful

Otherwise, it seems okay to me.

--yoshfuji
