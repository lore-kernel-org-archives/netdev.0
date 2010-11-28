From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]ipv6: kill two unused macro definition
Date: Sun, 28 Nov 2010 10:49:06 -0800 (PST)
Message-ID: <20101128.104906.39187120.davem@davemloft.net>
References: <4CEE14AC.7090008@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adobriyan@sw.ru
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36568
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754011Ab0K1Ssj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 13:48:39 -0500
In-Reply-To: <4CEE14AC.7090008@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Thu, 25 Nov 2010 15:47:56 +0800

> 1. IPV6_TLV_TEL_DST_SIZE
> This has not been using for several years since created.
> 
> 2. RT6_INFO_LEN
> commit 33120b30 kill all RT6_INFO_LEN's references, but only this definition remained.
> 
> commit 33120b30cc3b8665204d4fcde7288638b0dd04d5
> Author: Alexey Dobriyan <adobriyan@sw.ru>
> Date:   Tue Nov 6 05:27:11 2007 -0800
> 
>     [IPV6]: Convert /proc/net/ipv6_route to seq_file interface
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied.
