From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/12] sfc: Generalise link state monitoring
Date: Sun, 29 Nov 2009 16:48:09 -0800 (PST)
Message-ID: <20091129.164809.185906838.davem@davemloft.net>
References: <1259502180.3709.45.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57097
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752687AbZK3AsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 19:48:04 -0500
In-Reply-To: <1259502180.3709.45.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sun, 29 Nov 2009 13:43:00 +0000

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> Use the efx_nic_type::monitor operation or event handling as
> appropriate.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
