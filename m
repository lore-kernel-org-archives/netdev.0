From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ah4/ah6: remove useless NULL assignments
Date: Tue, 25 Nov 2008 01:05:16 -0800 (PST)
Message-ID: <20081125.010516.148235560.davem@davemloft.net>
References: <20081125033522.GA2617@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46225
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751995AbYKYJFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 04:05:16 -0500
In-Reply-To: <20081125033522.GA2617@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 25 Nov 2008 06:35:22 +0300

> struct will be kfreed in a moment, so...
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
