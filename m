From: Thomas Meyer <thomas@m3y3r.de>
Subject: Re: NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
Date: Thu, 07 Jun 2012 14:37:33 +0200
Message-ID: <1339072653.3018.9.camel@localhost.localdomain>
References: <1329063403.1449.14.camel@localhost.localdomain>
	 <CA+5PVA52+0vOMF6+tvMPkgzhdTKJRQnrjD4FfVmBZs0TMDJ5cg@mail.gmail.com>
	 <1329204997.24837.15.camel@edumazet-laptop>
	 <1329366846.5646.1.camel@edumazet-laptop>
	 <1329847015.5133.4.camel@localhost.localdomain>
	 <1329848093.18384.35.camel@edumazet-laptop>
	 <1330111229.15610.50.camel@edumazet-laptop>
	 <1330163565.1419.5.camel@localhost.localdomain>
	 <20120606003856.GA7839@burratino>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	jcliburn@gmail.com, chris.snook@gmail.com,
	netdev <netdev@vger.kernel.org>, Josh Boyer <jwboyer@gmail.com>
To: Jonathan Nieder <jrnieder@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www17.your-server.de ([213.133.104.17]:41274 "EHLO
	www17.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755957Ab2FGNJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 09:09:32 -0400
In-Reply-To: <20120606003856.GA7839@burratino>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, den 05.06.2012, 19:38 -0500 schrieb Jonathan Nieder:
> In February, 2012, Thomas Meyer wrote:
> > Am Freitag, den 24.02.2012, 20:20 +0100 schrieb Eric Dumazet:
> 
> >> Here is a cumulative patch to hopefuly remove the races in this driver,
> >> could you please test it ?
> [...]
> > just building a 3.2.7 kernel with your patch applied. I will watch out
> > for the warning in the next days.
> 
> Well, did it work? :)

Hi Jonathan,

no it didn't. I still get these warnings.

wiht kind regards
thomas

> 
> In suspense,
> Jonathan
