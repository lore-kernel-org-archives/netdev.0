From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 8 May 2007 17:52:01 +0200
Message-ID: <20070508155201.GA1251@xi.wantstofly.org>
References: <464034CF.20700@wpkg.org> <f19298770705080148u70638ac2ue87241382681088@mail.gmail.com> <m3bqgv72sq.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Tomasz Chmielewski <mangoo@wpkg.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Michael Jones <mlj28@cam.ac.uk>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:50301 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968266AbXEHPwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 11:52:04 -0400
Content-Disposition: inline
In-Reply-To: <m3bqgv72sq.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2007 at 05:28:21PM +0200, Krzysztof Halasa wrote:

> > I was always curious, why do people want to run ixp4xx in LE mode? What
> > are the benefits that overweight the obvious performance degradation?
> 
> Debian is indeed a valid reason.
> I wonder if it would be much work to create BE Debian as well.

There _is_ an ARM BE version of Debian.

It's not an official port, but it's not maintained any worse than
the 'official' LE ARM Debian port is.
