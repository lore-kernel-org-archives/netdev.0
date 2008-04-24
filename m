From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Thu, 24 Apr 2008 02:48:29 +0200
Message-ID: <m3iqy8f57m.fsf@maximus.localdomain>
References: <480E4FA1.5020508@garzik.org>
	<20080422.150559.115368150.davem@davemloft.net>
	<m34p9smrmp.fsf@maximus.localdomain>
	<20080423.154953.161012169.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, paulkf@microgate.com, jchapman@katalix.com,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:48426 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752872AbYDXAsc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2008 20:48:32 -0400
In-Reply-To: <20080423.154953.161012169.davem@davemloft.net> (David Miller's message of "Wed\, 23 Apr 2008 15\:49\:53 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> No, it was added as an optimization since the private
> area was allocated together with the struct netdev, and
> thus at a constant offset computable a compile time.

That's essentially what I meant. And it has changed, call it whatever
you wish.
-- 
Krzysztof Halasa
