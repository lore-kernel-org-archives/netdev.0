From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/5] be2net: support configuration of 64
 multicast addresses instead of 32
Date: Mon, 23 Nov 2009 10:45:41 -0800 (PST)
Message-ID: <20091123.104541.103895594.davem@davemloft.net>
References: <20091123080110.GA7726@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38685
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753334AbZKWSpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 13:45:23 -0500
In-Reply-To: <20091123080110.GA7726@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Mon, 23 Nov 2009 13:31:10 +0530

> To send upto 64 addresses in the multicast-set cmd, the non-embeeded cmd format
> that provides for a bigger buffer is used instead of an embedded format.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
