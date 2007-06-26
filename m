From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 26 Jun 2007 13:57:56 -0700 (PDT)
Message-ID: <20070626.135756.30187055.davem@davemloft.net>
References: <1182790051.5184.29.camel@localhost>
	<20070625.134741.129320846.davem@davemloft.net>
	<1182864448.5186.34.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38120
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757660AbXFZU5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 16:57:37 -0400
In-Reply-To: <1182864448.5186.34.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Tue, 26 Jun 2007 09:27:28 -0400

> Back to the question: Do you recall how this number was arrived at? 
> 128 packets will be sent out at GiGe in about 80 microsecs, so from a
> feel-the-wind-direction perspective it seems reasonable.

I picked it out of a hat.
