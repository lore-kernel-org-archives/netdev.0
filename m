From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] [PATCH] firmware: convert Ambassador ATM driver to request_firmware()
Date: Tue, 01 Jul 2008 12:17:15 -0400
Message-ID: <200807011617.m61GHF7c005071@cmf.nrl.navy.mil>
References: <1214917573.10393.391.camel@pmac.infradead.org>
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:53662 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699AbYGAQR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 12:17:26 -0400
In-reply-to: <1214917573.10393.391.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1214917573.10393.391.camel@pmac.infradead.org>,David Woodhouse writ
es:
>Perhaps so. But in that case why do we bother with MODULE_FIRMWARE at
>all? :)

dogged consistency or perhaps a shining beacon of correctness. :)
