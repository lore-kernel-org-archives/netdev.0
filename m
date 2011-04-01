From: David Miller <davem@davemloft.net>
Subject: Re: Driver for Asix AX88172A only?
Date: Fri, 01 Apr 2011 12:54:37 -0700 (PDT)
Message-ID: <20110401.125437.193712220.davem@davemloft.net>
References: <20110401165328.20091msct39m3en4@webmail.df.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael@riesch.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48005
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754857Ab1DATzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 15:55:15 -0400
In-Reply-To: <20110401165328.20091msct39m3en4@webmail.df.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Riesch <michael@riesch.at>
Date: Fri, 01 Apr 2011 16:53:28 +0200

> What do you think: should the mainline driver be adapted to support
> the AX88172A (with all his features) or a new driver for the AX88172A
> only should be created (probably based on the existing mainline
> driver).

I think the mainline driver should be adapted to support the new
chips with external PHYs etc.
