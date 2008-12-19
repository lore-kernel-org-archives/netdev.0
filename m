From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ppp_generic - use DEFINE_IDR for static
 initialization
Date: Thu, 18 Dec 2008 22:59:46 -0800 (PST)
Message-ID: <20081218.225946.98418595.davem@davemloft.net>
References: <20081218154636.GB12874@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, xemul@openvz.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paulus@samba.org
To: gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34261
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751507AbYLSG7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 01:59:45 -0500
In-Reply-To: <20081218154636.GB12874@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Thu, 18 Dec 2008 18:46:36 +0300

> net: ppp_generic - use DEFINE_IDR for static initialization
> 
> We could use DEFINE_IDR for statically allocated idr
> that allow us to save a few lines of code.
> 
> And spell fix.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>

Applied, thank you.
