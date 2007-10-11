From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][BNX2X] round three
Date: Thu, 11 Oct 2007 14:40:26 -0700 (PDT)
Message-ID: <20071011.144026.106275161.davem@davemloft.net>
References: <470D2D7E.8080507@broadcom.com>
	<20071010.175942.55509516.davem@davemloft.net>
	<1192125219.29746.143.camel@eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, mchan@broadcom.com
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46832
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754954AbXJKVki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 17:40:38 -0400
In-Reply-To: <1192125219.29746.143.camel@eliezer>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Thu, 11 Oct 2007 19:53:39 +0200

> Will it be OK if we replace it with 4-5 headers so we can maintain them
> better manually. (I'm asking what is the upper bound to the number of
> header files you would consider reasonable for this driver.)

It's not the count, it's what's in them that's the problem.
