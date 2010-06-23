From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 0/8]qlcnic: driver update
Date: Wed, 23 Jun 2010 12:04:29 -0700 (PDT)
Message-ID: <20100623.120429.39171086.davem@davemloft.net>
References: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32768
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751322Ab0FWTER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 15:04:17 -0400
In-Reply-To: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: amit.salecha@qlogic.com
Date: Tue, 22 Jun 2010 06:18:57 -0700

>   Major changes:
>   1) Previously device context were created in probe and released in remove.
>      Now create during interface up and release in interface down.
>   2) Dont deallocate and allocate host memory during device reset.
>   3) Offload tx timeout recovery to fw recovery functions. Later will
>      check fw health before doing tx timeout recovery.
> 
>   Series of 8 patches. Please apply them on net-next branch.

All applied, thank you.
