From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ll_temac: Add support for V2 LLTEMAC core
Date: Wed, 17 Feb 2010 13:42:47 -0800 (PST)
Message-ID: <20100217.134247.169742000.davem@davemloft.net>
References: <1266426860-5634-1-git-send-email-steve@digidescorp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: steve@digidescorp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57262
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757293Ab0BQVmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:42:31 -0500
In-Reply-To: <1266426860-5634-1-git-send-email-steve@digidescorp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Steven J. Magnani" <steve@digidescorp.com>
Date: Wed, 17 Feb 2010 11:14:20 -0600

> LLTEMAC V1 cores place only received packet length in the app4 word.
> V2 cores place additional information in app4.
> Mask out the additional information when retrieving the packet length.
> 
> Signed-off-by: Steven J. Magnani <steve@digidescorp.com>

Applied.
