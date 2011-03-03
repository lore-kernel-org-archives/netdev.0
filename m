From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] tg3: Enclose macro with complex values in
 parenthesis
Date: Wed, 02 Mar 2011 20:56:01 -0800 (PST)
Message-ID: <20110302.205601.71129255.davem@davemloft.net>
References: <1298999069-12740-1-git-send-email-martinez.javier@gmail.com>
	<1298999069-12740-3-git-send-email-martinez.javier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com,
	grant.likely@secretlab.ca, netdev@vger.kernel.org,
	kernelnewbies@kernelnewbies.org
To: martinez.javier@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52031
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757440Ab1CCEzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 23:55:24 -0500
In-Reply-To: <1298999069-12740-3-git-send-email-martinez.javier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Javier Martinez Canillas <martinez.javier@gmail.com>
Date: Tue,  1 Mar 2011 18:04:27 +0100

> Macros with complex values should be enclosed in parenthesis.
> Change accordingly.
> 
> Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>

This seems unnecessary, what problem do the current macro definitions
create?
