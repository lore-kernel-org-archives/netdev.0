From: Marcus Better <marcus@better.se>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Wed, 09 May 2007 10:58:06 +0200
Message-ID: <f1s2eu$26p$1@sea.gmane.org>
References: <464034CF.20700@wpkg.org> <f19298770705080148u70638ac2ue87241382681088@mail.gmail.com> <m3bqgv72sq.fsf@maximus.localdomain> <20070508155201.GA1251@xi.wantstofly.org> <m3hcqn5j0p.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:33157 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754443AbXEII6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 04:58:20 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Hlhzz-00021g-GQ
	for netdev@vger.kernel.org; Wed, 09 May 2007 10:58:15 +0200
Received: from 67.152.216.81.static.g-va.siw.siwnet.net ([81.216.152.67])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 09 May 2007 10:58:15 +0200
Received: from marcus by 67.152.216.81.static.g-va.siw.siwnet.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 09 May 2007 10:58:15 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Halasa wrote:
> Lennert Buytenhek <buytenh@wantstofly.org> writes:
>> There _is_ an ARM BE version of Debian.
>>
>> It's not an official port, but it's not maintained any worse than
>> the 'official' LE ARM Debian port is.

> Hmm... That changes a bit. Perhaps we should forget about
> that LE thing then, and (at best) put that trivial workaround?

Please keep in mind that users are unlikely to install an unofficial port
which lacks integration with the Debian infrastructure, security support
and other services. The arm architecture (LE) is currently the third most
popular in Debian, whereas I suspect (?) there are very few BE Debian
systems out there.

Marcus


