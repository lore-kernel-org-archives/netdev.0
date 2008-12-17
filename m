From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH 0/5] Phonet enhancements
Date: Wed, 17 Dec 2008 15:46:55 -0800 (PST)
Message-ID: <20081217.154655.244245012.davem@davemloft.net>
References: <200812171607.14184.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38417
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752041AbYLQXqx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 18:46:53 -0500
In-Reply-To: <200812171607.14184.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Wed, 17 Dec 2008 16:07:14 +0200

> This simplifies the GPRS over Phonet virtual interface driver, and
> adds support for a Phonet USB gadget (the latter will need to go
> through linux-usb?). Comments welcome.

I'll put the USB bits into net-next-2.6 for now.

If it causes merge hassles for the USB folks we'll need
to figure something out, but I doubt it will cause
real problems.
