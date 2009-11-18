From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] TI EMAC driver : Make driver re-usable on
 non-davinci platforms.
Date: Wed, 18 Nov 2009 05:12:22 -0800 (PST)
Message-ID: <20091118.051222.28644047.davem@davemloft.net>
References: <1258537328-31527-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: srk@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40097
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751660AbZKRNMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 08:12:05 -0500
In-Reply-To: <1258537328-31527-1-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriramakrishnan <srk@ti.com>
Date: Wed, 18 Nov 2009 15:12:05 +0530

> The Davinci EMAC peripheral is also available on other TI platforms -
> notably TI AM3517 SoC. The following series of patches modify the driver 
> suitably to make it platform agnostic.
> 
> Sriramakrishnan (3):
>   TI Davinci EMAC : Re-use driver for other platforms.
>   TI Davinci EMAC : add platform specific interrupt enable/disable
>     logic.
>   TI Davinci EMAC : Abstract Buffer address translation logic.

It is easier to send this through the ARM tree?  If so, feel free
to do that and add my:

Acked-by: David S. Miller <davem@davemloft.net>

Thanks.
