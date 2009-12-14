From: christian pellegrin <chripell@fsfe.org>
Subject: Re: [PATCH] can: CAN_MCP251X should depend on HAS_DMA
Date: Mon, 14 Dec 2009 09:14:27 +0100
Message-ID: <cabda6420912140014i5693f17p2d00a82ff3a4a3bc@mail.gmail.com>
References: <alpine.DEB.2.00.0912132008100.21225@ayla.of.borg>
	 <4B2552C8.4090105@grandegger.com>
	 <20091213.174020.26980813.davem@davemloft.net>
	 <4B25EA8B.1030507@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, geert@linux-m68k.org,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:54011 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbZLNIO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 03:14:28 -0500
In-Reply-To: <4B25EA8B.1030507@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 14, 2009 at 8:34 AM, Wolfgang Grandegger <wg@grandegger.com> wrote:
> David Miller wrote:
>>
>> I still think it's a reasonable dependency.
>>
>> You're not going to find this device on a s390 system. :-)
>
> OK, we could change that on request.
>
> Wolfgang.
>

Hi, sorry for the late answer. I agree it's a reasonable dependency.
Anyway it's easy to #ifdef it out if anyone cares.

Bye,

-- 
Christian Pellegrin, see http://www.evolware.org/chri/
"Real Programmers don't play tennis, or any other sport which requires
you to change clothes. Mountain climbing is OK, and Real Programmers
wear their climbing boots to work in case a mountain should suddenly
spring up in the middle of the computer room."
