From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: Use explicit designated initializers for .cmd
Date: Thu, 11 Feb 2010 12:14:34 -0800 (PST)
Message-ID: <20100211.121434.97316024.davem@davemloft.net>
References: <adatytn7crt.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42886
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756400Ab0BKUOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 15:14:21 -0500
In-Reply-To: <adatytn7crt.fsf@roland-alpha.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Thu, 11 Feb 2010 12:12:06 -0800

> Initialize the .cmd member of various ethtool using a designated struct
> initializer rather.  This makes things a teeny bit more robust, although
> the chance of a struct layout changing is extremely remote, and also
> makes the code a little easier to read.
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>

Applied to net-next-2.6, thanks Roland.
