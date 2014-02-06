From: Marek Vasut <marex@denx.de>
Subject: Re: Freescale FEC packet loss
Date: Thu, 6 Feb 2014 14:41:20 +0100
Message-ID: <201402061441.20475.marex@denx.de>
References: <201401222255.29467.marex@denx.de> <201401280201.39174.marex@denx.de> <CAH9NwWeK17kfty-BAA9Y977BGTYBcJLRSRESrfbCvQ_BiVxa0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben@decadent.org.uk>,
	"fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Frank Li <Frank.Li@freescale.com>, Detlev Zundel <dzu@denx.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Nelson <eric.nelson@boundarydevices.com>,
	Hector Palacios <hector.palacios@digi.com>,
	fugang.duan@freescale.com,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Christian Gmeiner <christian.gmeiner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:58439 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbaBFOHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 09:07:42 -0500
In-Reply-To: <CAH9NwWeK17kfty-BAA9Y977BGTYBcJLRSRESrfbCvQ_BiVxa0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, February 06, 2014 at 10:42:00 AM, Christian Gmeiner wrote:

[...]

> Are there still problems with 3.13.1 kernel regarding FEC networking?

They are on 3.13.0 and I don't see any network-related fixes in 3.13.1 .

> Does this only
> affect the SabreLite?

No, this is not board-specific. This affects different boards and different MX6 
CPUs.

Best regards,
Marek Vasut
