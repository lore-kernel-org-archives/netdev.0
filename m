From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pcnet_cs: add new id
Date: Tue, 30 Jun 2009 07:19:55 -0700 (PDT)
Message-ID: <20090630.071955.193724693.davem@davemloft.net>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090628090939.c04680a3.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53942
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752045AbZF3OTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 10:19:49 -0400
In-Reply-To: <20090628090939.c04680a3.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Sun, 28 Jun 2009 09:09:39 +0900

> 
> pcnet_cs:
> 
> (1) add new id (RIOS System PC CARD3 ETHERNET).
> 
> (2) add odd location support for write_asic function.
> 
> (3) change default setting of use_shmem to 0.
>     because shared memory does not work on some PC.
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

These are three seperate changes, could you split this up
into three seperate patches?

Thank you.
