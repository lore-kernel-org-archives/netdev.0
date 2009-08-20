From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Strange network timeouts w/ 2.6.30.5
Date: Thu, 20 Aug 2009 11:22:35 +0200
Message-ID: <m3iqgiet5w.fsf@intrepid.localdomain>
References: <2087985663.21250727676944.JavaMail.root@mail.holmansrus.com>
	<20090819.211736.222582824.davem@davemloft.net>
	<m3my5ueu2a.fsf@intrepid.localdomain>
	<20090820.021330.151477484.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: walt@holmansrus.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:58270 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753423AbZHTJWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 05:22:36 -0400
In-Reply-To: <20090820.021330.151477484.davem@davemloft.net> (David Miller's message of "Thu\, 20 Aug 2009 02\:13\:30 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> skb->data is where e100 puts it's descriptors. :-)
>
> But you know that.

Right. I will try to change that soon.
-- 
Krzysztof Halasa
