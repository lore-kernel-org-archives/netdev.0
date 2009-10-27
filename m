From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: Add asm/cacheflush.h
Date: Mon, 26 Oct 2009 17:28:38 -0700 (PDT)
Message-ID: <20091026.172838.53981588.davem@davemloft.net>
References: <29ab51dc0910261649p2fb22799o5cc70a71dff0f1dd@mail.gmail.com>
	<20091026.171956.110203653.davem@davemloft.net>
	<20091027002525.GA17085@linux-sh.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: iwamatsu@nigauri.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: lethal@linux-sh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34939
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755491AbZJ0A2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 20:28:15 -0400
In-Reply-To: <20091027002525.GA17085@linux-sh.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Mundt <lethal@linux-sh.org>
Date: Tue, 27 Oct 2009 09:25:25 +0900

> On Mon, Oct 26, 2009 at 05:19:56PM -0700, David Miller wrote:
>> From: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
>> Date: Tue, 27 Oct 2009 08:49:50 +0900
>> 
>> > Add include asm/cacheflush.h,  because declaration of __flush_purge_region
>> > moved to asm/cacheflush.h.
>> > 
>> > Signed-off-by: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
>> 
>> Applied, thanks.
> 
> Even though Iwamatsu-san didn't specify the kernel version, this is
> relevant for 2.6.32 (as that's where we made the change).

Ok.
