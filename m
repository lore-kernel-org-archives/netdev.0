From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8] Remove bogus zero_it argument from sk_alloc
Date: Thu, 01 Nov 2007 00:38:59 -0700 (PDT)
Message-ID: <20071101.003859.19874242.davem@davemloft.net>
References: <472885B1.7090103@openvz.org>
	<4728897A.50607@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35395
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753391AbXKAHi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 03:38:59 -0400
In-Reply-To: <4728897A.50607@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 31 Oct 2007 16:56:10 +0300

> At this point nobody calls the sk_alloc(() with zero_it == 0,
> so remove unneeded checks from it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
