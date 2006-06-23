From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Memory corruption in 8390.c ?
Date: Thu, 22 Jun 2006 23:32:21 -0400
Message-ID: <449B60C5.50709@pobox.com>
References: <E1FtNNQ-0001QW-00@gondolin.me.apana.org.au> <1150982734.15275.166.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	snakebyte@gmx.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43911 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751222AbWFWDci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 23:32:38 -0400
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1150982734.15275.166.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

applied except for orinoco, which failed to apply (rediff?)

