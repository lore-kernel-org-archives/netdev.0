From: khalasa@piap.pl (Krzysztof =?utf-8?Q?Ha=C5=82asa?=)
Subject: Re: [PATCH] I.MX6: Fix Ethernet PHY mode on Ventana boards
Date: Wed, 09 Dec 2015 06:50:27 +0100
Message-ID: <m3vb88b270.fsf@t19.piap.pl>
References: <m3egeyct8o.fsf@t19.piap.pl>
	<20151208.122447.863577308058835164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: tharvey@gateworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ni.piap.pl ([195.187.100.4]:60113 "EHLO ni.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750920AbbLIFua (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2015 00:50:30 -0500
In-Reply-To: <20151208.122447.863577308058835164.davem@davemloft.net> (David
	Miller's message of "Tue, 08 Dec 2015 12:24:47 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> Since this only touched DT files in the ARM platform code, maybe
> the ARM tree is the best path for this patch rather than mine?

I think so.

Tim, would you like to handle this patch yourself, or should I send it
to the ARM contacts?
-- 
Krzysztof Halasa

Industrial Research Institute for Automation and Measurements PIAP
Al. Jerozolimskie 202, 02-486 Warsaw, Poland
