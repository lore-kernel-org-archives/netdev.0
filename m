From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] [SK_BUFF]: Adjust the zeroing up to tail in
 __alloc_skb too
Date: Mon, 19 Mar 2007 14:40:59 -0700 (PDT)
Message-ID: <20070319.144059.18576524.davem@davemloft.net>
References: <20070319135030.GE17811@ghostprotocols.net>
	<20070319.121622.55507267.davem@davemloft.net>
	<39e6f6c70703191348w6ab21c32nefd9a0fdfcc90917@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49272
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030608AbXCSVk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 17:40:59 -0400
In-Reply-To: <39e6f6c70703191348w6ab21c32nefd9a0fdfcc90917@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Mon, 19 Mar 2007 17:48:02 -0300

> OK, I wasn' t expecting any whitspaces, probably were whitespaces
> already there that were kept,

I am pretty sure this is exactly what happened.

> I'll try and check future patches.

Thanks!
