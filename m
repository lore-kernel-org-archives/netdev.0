From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] HIP IP protocol number
Date: Tue, 29 Apr 2008 03:25:19 -0700 (PDT)
Message-ID: <20080429.032519.250908926.davem@davemloft.net>
References: <200804281504.01798.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joakim.koskela@hiit.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35303
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751007AbYD2KZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 06:25:20 -0400
In-Reply-To: <200804281504.01798.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Koskela <joakim.koskela@hiit.fi>
Date: Mon, 28 Apr 2008 15:04:01 +0300

> This just adds the IP protocol number for the Host Identity Protocol
> (described in RFC5201), recently assigned by the IANA.
> 
> Signed-off-by: Joakim Koskela <jookos@gmail.com>

Every value currently listed in this list has a usage inside
of the kernel.

Until there is an in-kernel usage of your new value, there is
no reason to add it here.
