From: David Miller <davem@davemloft.net>
Subject: Re: [PING^2] [PATCH] srandom32 fixes for networking
Date: Wed, 02 Apr 2008 00:18:24 -0700 (PDT)
Message-ID: <20080402.001824.161259886.davem@davemloft.net>
References: <20080401113408.GA625@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53220
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759248AbYDBHSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 03:18:24 -0400
In-Reply-To: <20080401113408.GA625@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 1 Apr 2008 13:34:08 +0200

> Still missing from net-2.6.26
> 
> http://marc.info/?l=linux-netdev&m=120519912215170&w=2
> 
> Please add or justify rejection.

Please fix this patch so that the arch/x86/mm/pageattr-test.c
build doesn't get broken by it.
