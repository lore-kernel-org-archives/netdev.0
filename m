From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: make default for INET_LRO consistent with help
 text
Date: Mon, 18 May 2009 21:49:10 -0700 (PDT)
Message-ID: <20090518.214910.41457086.davem@davemloft.net>
References: <200905150851.08286.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: elendil@planet.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52012
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753646AbZESEtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 00:49:12 -0400
In-Reply-To: <200905150851.08286.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frans Pop <elendil@planet.nl>
Date: Fri, 15 May 2009 08:51:06 +0200

> Commit e81963b1 changed this config from tristate to bool.
> Add default so that it is consistent with the help text.
> 
> Signed-off-by: Frans Pop <elendil@planet.nl>

Applied, but please also reference commits by header text,
like this:

    ipv4: make default for INET_LRO consistent with help text
    
    Commit e81963b1 ("ipv4: Make INET_LRO a bool instead of tristate.")
    changed this config from tristate to bool.  Add default so that it is
    consistent with the help text.

Thanks.
