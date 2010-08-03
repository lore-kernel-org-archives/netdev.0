From: Cyril Chemparathy <cyril@ti.com>
Subject: Re: [PATCH 2/8] davinci: add mdio platform devices
Date: Tue, 03 Aug 2010 10:32:25 -0400
Message-ID: <4C582879.7060708@ti.com>
References: <1280842313-3743-1-git-send-email-cyril@ti.com> <1280842313-3743-3-git-send-email-cyril@ti.com> <4C58227A.4080502@compulab.co.il>
Reply-To: cyril@ti.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"Nori, Sekhar" <nsekhar@ti.com>,
	"Govindarajan, Sriramakrishnan" <srk@ti.com>
To: Igor Grinberg <grinberg@compulab.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:35686 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995Ab0HCOcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 10:32:32 -0400
In-Reply-To: <4C58227A.4080502@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Igor,

> Shouldn't arch/arm/mach-omap2/board-am3517evm.c be on your list?
> I think it should, or else it will be broken by:
> [PATCH 5/8] netdev: cleanup unused davinci mdio emac code

Correct.  As stated in the series summary:

> Additional omap tree patches will be required for am35xx as well
> (not included here).

Regards
Cyril.
