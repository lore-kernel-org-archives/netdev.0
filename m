From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6 - Add missing initializations of the new
 nl_info.nl_net field
Date: Tue, 26 Feb 2008 18:10:15 -0800 (PST)
Message-ID: <20080226.181015.93676813.davem@davemloft.net>
References: <20080221165219.657302066@theryb.frec.bull.fr>
	<20080223.200257.24167841.davem@davemloft.net>
	<20080225095039.127441518@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38798
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751866AbYB0CJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 21:09:30 -0500
In-Reply-To: <20080225095039.127441518@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Mon, 25 Feb 2008 10:50:23 +0100

> Here is an updated version of the patch without the initializations to 
> "zero".
> 
> 
> Add some more missing initializations of the new nl_info.nl_net field in 
> IPv6 stack. This field will be used when network namespaces are fully 
> supported.
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied, thanks Benjamin.
