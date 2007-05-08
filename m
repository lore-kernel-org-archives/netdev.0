From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 08 May 2007 19:20:54 +0200
Message-ID: <m3hcqn5j0p.fsf@maximus.localdomain>
References: <464034CF.20700@wpkg.org>
	<f19298770705080148u70638ac2ue87241382681088@mail.gmail.com>
	<m3bqgv72sq.fsf@maximus.localdomain>
	<20070508155201.GA1251@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Tomasz Chmielewski <mangoo@wpkg.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Michael Jones <mlj28@cam.ac.uk>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:44168 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754512AbXEHRUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 13:20:55 -0400
In-Reply-To: <20070508155201.GA1251@xi.wantstofly.org> (Lennert Buytenhek's message of "Tue, 8 May 2007 17:52:01 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek <buytenh@wantstofly.org> writes:

> There _is_ an ARM BE version of Debian.
>
> It's not an official port, but it's not maintained any worse than
> the 'official' LE ARM Debian port is.

Hmm... That changes a bit. Perhaps we should forget about
that LE thing then, and (at best) put that trivial workaround?
-- 
Krzysztof Halasa
