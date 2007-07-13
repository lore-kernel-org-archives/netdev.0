From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] IPROUTE2: Fix bug  in display of ipv6 cloned/cached	routes
Date: Fri, 13 Jul 2007 14:53:49 +0200
Message-ID: <469775DD.3090302@trash.net>
References: <1184179063.16607.9.camel@localhost.localdomain>	 <4695257E.8080105@trash.net> <1184268044.12609.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41373 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757492AbXGMMyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 08:54:09 -0400
In-Reply-To: <1184268044.12609.21.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sridhar Samudrala wrote:
> I found an issue with my original patch. If cache/cloned is 
> specified, it dumps the cloned routes irrespective of the table
> specified. I think this is a better fix and also should address
> the case you were mentioning above.


Your patch looks good, thanks.

