From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [PATCH RFC] ipv6: stable privacy addresses
Date: Mon, 16 Dec 2013 19:27:51 +0100
Message-ID: <52AF4627.90508@enst-bretagne.fr>
References: <20131213085549.GA3685@order.stressinduktion.org> <52AAE273.7070806@enst-bretagne.fr> <20131213115033.GA7332@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fgont@si6networks.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:51603 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754689Ab3LPS1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 13:27:52 -0500
In-Reply-To: <20131213115033.GA7332@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> You configuration is for all interfaces the same, isn't? I would like a
>> configuration possibility per interface, to mix EUI64 and stable privacy
>> addresses on the same device.
> 
> You mean like EUI-64 link-local and privacy-stable ones for global scope?
> This indeed does sound useful.
> 

Yes, and to mix configuration with several interfaces. One can set the
eth0 interface with EUI-64 for global scope, and wlan0 with
privacy-stable for global scope.

Regards,

Florent.
