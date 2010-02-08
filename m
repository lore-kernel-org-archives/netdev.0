From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v2 00/41] CAPI: Major rework, tons of bug fixes
Date: Mon, 8 Feb 2010 21:38:59 +0000
Message-ID: <20100208213859.1ee8241a@lxorguk.ukuu.org.uk>
References: <cover.1265659933.git.jan.kiszka@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>
To: Jan Kiszka <jan.kiszka@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:58705 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751259Ab0BHVik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 16:38:40 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  o reworked locking of the NCCI TTY using latest and greatest tty_port
>    features and kref, hopefully in the right way

Looks sane to me

Alan
