From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Remove redundant NAPI functions
Date: Thu, 08 Jan 2009 12:54:58 -0800 (PST)
Message-ID: <20090108.125458.198312862.davem@davemloft.net>
References: <1231446610.3893.17.camel@achroite>
	<1231447246.1739.61.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, nhorman@tuxdriver.com,
	shemminger@vyatta.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49466
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752187AbZAHUy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 15:54:56 -0500
In-Reply-To: <1231447246.1739.61.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 08 Jan 2009 12:40:46 -0800

> napi was just new-api.
> Why persist what seems a poor naming choice?

Maybe because "NAPI" has been ingrained into everyone's skull for the
past 10+ years?
