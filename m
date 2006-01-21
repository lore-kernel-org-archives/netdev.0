From: <samuel@sortiz.org>
Subject: Re: [PATCH 2/2] IRDA: Do cleanup for dma
Date: Sat, 21 Jan 2006 07:07:16 +0100
Message-ID: <6fe1847af5073e7f50519a2ebc730653@localhost>
References: <48365CBF.4080502@cn.fujitsu.com> <20080529.033442.175635712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: wangchen@cn.fujitsu.com, jgarzik@pobox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 25.mail-out.ovh.net ([213.186.37.103]:38989 "HELO
	25.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754960AbYE2NsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 09:48:04 -0400
In-Reply-To: <20080529.033442.175635712.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Dave,



On Thu, 29 May 2008 03:34:42 -0700 (PDT), David Miller

<davem@davemloft.net> wrote:

> From: Wang Chen <wangchen@cn.fujitsu.com>

> Date: Fri, 23 May 2008 13:57:19 +0800

> 

>> 1. dma should be freed when dma2 request fail.

>> 2. dma2 should be freed too when device close.

>>

>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

> 

> Jeff, did you get this or would you like me to pick

> it up directly?

I'll take it and send it along with my next IrDA patch set.



Cheers,

Samuel.





> Thanks.

> --

> To unsubscribe from this list: send the line "unsubscribe netdev" in

> the body of a message to majordomo@vger.kernel.org

> More majordomo info at  http://vger.kernel.org/majordomo-info.html

