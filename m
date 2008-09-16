From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 00/14] [RFC] Phonet protocol stack
Date: Tue, 16 Sep 2008 22:09:04 +0200
Message-ID: <1221595744.4989.4.camel@californication>
References: <200809161757.38571.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37434 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbYIPUIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 16:08:22 -0400
In-Reply-To: <200809161757.38571.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Remi,

> This patch series introduces support for PhoNet,
> the "Phone Network protocol". This protocol is the primary interface
> to Nokia cellular modem engines. We are integrating it to the Linux
> kernel in order to support HSPA cellular data connectivity on the
> Maemo Software platform.

nice to see that this finally becomes open source.

> This patchset provides a simple datagram socket 
> independent of the underlying hardware (network interface) through
> which the modem is attached. We are in the process of contributing
> a lower-layer driver through Linux OMAP.

We are using PhoNet over Bluetooth and IrDA inside the Gnokii project
and if we have a common PhoNet stack inside the Linux kernel that is
supported by Nokia, I do wanna use that. What are your plans for this?

Regards

Marcel


