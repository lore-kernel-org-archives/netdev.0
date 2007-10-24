From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Remove in-code externs for some functions from
 net/core/dev.c
Date: Tue, 23 Oct 2007 21:14:53 -0700 (PDT)
Message-ID: <20071023.211453.35661191.davem@davemloft.net>
References: <471CC0FE.9030602@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58819
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751999AbXJXEPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 00:15:09 -0400
In-Reply-To: <471CC0FE.9030602@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 22 Oct 2007 19:25:50 +0400

> Inconsistent prototype and real type for functions may have
> worse consequences, than those for variables, so move them
> into a header.
> 
> Since they are used privately in net/core, make this file
> reside in the same place.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
