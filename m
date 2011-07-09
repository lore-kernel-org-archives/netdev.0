From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFC PATCH] net: clean up rx_copybreak handling
Date: Sat, 9 Jul 2011 12:44:28 +0200
Message-ID: <20110709104428.GB6437@rere.qmqm.pl>
References: <f73b8ed0717151cd2c72e5c23d275cc0de28d277.1310167326.git.mirq-linux@rere.qmqm.pl>
 <1310175469.26320.9.camel@obelisk.thedillows.org>
 <20110709085444.GA5522@rere.qmqm.pl>
 <20110709.025729.1469467150725305489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dave@thedillows.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:57744 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751955Ab1GIKob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 06:44:31 -0400
Content-Disposition: inline
In-Reply-To: <20110709.025729.1469467150725305489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 09, 2011 at 02:57:29AM -0700, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Sat, 9 Jul 2011 10:54:44 +0200
> > What about the patch's general idea?
> I fully support the idea behind your changes.

Let's start with the implementation then (patch will follow).

Best Regards,
Micha=B3 Miros=B3aw
