From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cassini: NAPI configuration
Date: Thu, 22 Nov 2007 17:00:08 -0800 (PST)
Message-ID: <20071122.170008.193709839.davem@davemloft.net>
References: <20071121115358.2e31fb91@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51737
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751409AbXKWBAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 20:00:09 -0500
In-Reply-To: <20071121115358.2e31fb91@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 21 Nov 2007 11:53:58 -0800

> The Cassini driver has NAPI support, but it not possible to configure it.
> Compile tested only, no idea if it works (no hardware).
> Get rid of warning from lefover variable in now visible code.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

This driver needs massive amounts of work, and along with some
contacts within Sun I plan to make this soon after I get back
from Korea.

Therefore, please leave this stuff alone for a bit.

Thanks.
