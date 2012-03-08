From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [REPOST PATCH] net/usbnet: avoid recursive locking in usbnet_stop()
Date: Thu, 8 Mar 2012 09:38:17 +0100
Message-ID: <201203080938.17604.oneukum@suse.de>
References: <20120307201928.GA30188@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39648 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753048Ab2CHIfZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 03:35:25 -0500
In-Reply-To: <20120307201928.GA30188@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 7. M=E4rz 2012, 21:19:28 schrieb Sebastian Andrzej Siewior=
:
> Cc: stable@kernel.org
> Reported-by: An=C3=ADbal Almeida Pinto <anibal.pinto@efacec.com>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Acked-by: Oliver Neukum <oliver@neukum.org>
