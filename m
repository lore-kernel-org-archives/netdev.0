From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] filter: cleanup codes[] init
Date: Fri, 19 Nov 2010 10:07:20 -0800 (PST)
Message-ID: <20101119.100720.115931285.davem@davemloft.net>
References: <AANLkTikxUnj-_ov_5o6zDffv2M8J8JJg-M5HS6dr4s=a@mail.gmail.com>
	<1290160467.3034.33.camel@edumazet-laptop>
	<AANLkTi=GLX-biB0ApDFMD2GOYyqb2qghMSHScmBTJv-O@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hagen@jauu.net, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35787
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756170Ab0KSSG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 13:06:56 -0500
In-Reply-To: <AANLkTi=GLX-biB0ApDFMD2GOYyqb2qghMSHScmBTJv-O@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Fri, 19 Nov 2010 20:21:57 +0800

> On Fri, Nov 19, 2010 at 5:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>> Most probably you have "CONFIG_CC_OPTIMIZE_FOR_SIZE=y" which
>> unfortunately is known to generate poor looking code.
> 
> Yes. So
> 
> Acked-by: Changli Gao <xiaosuo@gmail.com>

Applied.
