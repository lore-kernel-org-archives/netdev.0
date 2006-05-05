From: Thomas Glanzmann <sithglan@stud.uni-erlangen.de>
Subject: Re: sky2 1.3-rc1
Date: Fri, 5 May 2006 19:35:09 +0200
Message-ID: <20060505173509.GK2757@cip.informatik.uni-erlangen.de>
References: <1146667951.3056.25.camel@fc5test.deadmoose.com> <20060503120507.4558c675@localhost.localdomain> <445B626B.1070407@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Bill Hoover <bill@luminescent.com>,
	Bertrand Jacquin <beber@gna.org>, micheleschi@libero.it,
	netdev@vger.kernel.org, teppic74@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui03.informatik.uni-erlangen.de ([131.188.30.103]:41860 "EHLO
	faui03.informatik.uni-erlangen.de") by vger.kernel.org with ESMTP
	id S1751675AbWEERfL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 13:35:11 -0400
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <445B626B.1070407@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

> >	http://developer.osdl.org/shemminger/prototypes/sky2-1.3-rc1.tar.bz2

> v0.15:
> 64 bytes from 10.0.0.138: icmp_seq=2 ttl=64 time=0.467 ms

> v1.3-rc1:
> 64 bytes from 10.0.0.138: icmp_seq=4 ttl=64 time=32.9 ms

I can't confirm this. For me it is just perfect:

64 bytes from 89.106.66.1: icmp_seq=1 ttl=64 time=0.278 ms

0000:04:00.0 Ethernet controller: Marvell Technology Group Ltd.: Unknown device 4361 (rev 17)

        Thomas
