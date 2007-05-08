From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 08 May 2007 19:51:29 +0200
Message-ID: <m31whr5hlq.fsf@maximus.localdomain>
References: <464034CF.20700@wpkg.org>
	<f19298770705080148u70638ac2ue87241382681088@mail.gmail.com>
	<m3bqgv72sq.fsf@maximus.localdomain>
	<20070508155201.GA1251@xi.wantstofly.org>
	<m3hcqn5j0p.fsf@maximus.localdomain> <4640B3EE.1020707@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michael Jones <mlj28@cam.ac.uk>
To: Tomasz Chmielewski <mangoo@wpkg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:47259 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966751AbXEHRvb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 13:51:31 -0400
In-Reply-To: <4640B3EE.1020707@wpkg.org> (Tomasz Chmielewski's message of "Tue, 08 May 2007 19:31:26 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tomasz Chmielewski <mangoo@wpkg.org> writes:

> Does using ixp4xx on LE have any other drawbacks than inferior network
> performance?

More memory is needed, something like max 600 KB for 2 Ethernet ports.

> And talking about network performance, what numbers are we talking
> about (LE vs BE; 30% performance hit on LE, more, or less)?

Haven't checked yet but I'd expect something like that.
-- 
Krzysztof Halasa
