From: David Miller <davem@davemloft.net>
Subject: Re: [3/5][TG3]: Enable auto MDI.
Date: Wed, 11 Jul 2007 19:48:37 -0700 (PDT)
Message-ID: <20070711.194837.122831876.davem@davemloft.net>
References: <1184196735.5211.10.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46244
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758110AbXGLCsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 22:48:14 -0400
In-Reply-To: <1184196735.5211.10.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 11 Jul 2007 16:32:15 -0700

> [TG3]: Enable auto MDI.
> 
> This patch adds automatic MDI crossover support when autonegotiation is
> turned off.  Automatic MDI crossover allows link to be established
> without the use of a crossover cable.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
