From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/12] sfc: Fold falcon_probe_nic_variant() into
 falcon_probe_nic()
Date: Sun, 29 Nov 2009 17:24:13 -0800 (PST)
Message-ID: <20091129.172413.195706177.davem@davemloft.net>
References: <1259543301.3709.84.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46030
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751017AbZK3BYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:24:08 -0500
In-Reply-To: <1259543301.3709.84.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 30 Nov 2009 01:08:21 +0000

> falcon_probe_nic_variant() does a lot less than it used to, and a
> lot less than it claims to.  Fold the remainder into its caller.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
