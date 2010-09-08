From: David Miller <davem@davemloft.net>
Subject: Re: [Bug #16626] Machine hangs with EIP at skb_copy_and_csum_dev
Date: Wed, 08 Sep 2010 10:32:56 -0700 (PDT)
Message-ID: <20100908.103256.112592448.davem@davemloft.net>
References: <1283672983.3402.38.camel@edumazet-laptop>
	<4C8717BB.2050504@fs.uni-ruse.bg>
	<20100908062004.GA6280@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pvp-lsts@fs.uni-ruse.bg, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, rjw@sisk.pl,
	kernel-testers@vger.kernel.org, maciej.rutecki@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54144
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751716Ab0IHRci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 13:32:38 -0400
In-Reply-To: <20100908062004.GA6280@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 8 Sep 2010 06:20:04 +0000

> We need both of them. I hope David could add this too:
> 
> Tested-by: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>

Done, and applied, thanks :-)
