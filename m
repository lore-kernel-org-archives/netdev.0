From: "David H. Lynch Jr." <dhlii@dlasys.net>
Subject: Re: Fwd: That whole "Linux stealing our code" thing
Date: Wed, 05 Sep 2007 09:22:21 -0400
Message-ID: <46DEAD8D.9020008@dlasys.net>
References: <200709010140.l811eq9H005896@cvs.openbsd.org> <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com> <46D99FB7.6030505@garzik.org> <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com> <20070901205457.GK9260@stusta.de> <20070902113638.78fbd202@the-village.bc.nu> <Pine.LNX.4.64.0709021303001.4312@condmat1.ciencias.uniovi.es> <20070902115041.GM16016@stusta.de> <Pine.LNX.4.64.0709021416130.6181@condmat1.ciencias.uniovi.es> <20070902134612.28a88761@the-village.bc.nu> <Pine.LNX.4.64.0709021446550.6181@condmat1.ciencias.uniovi.es> <m3642txj91.fsf@maximus.localdomain> <46DAC482.5090107@garzik.org> <Pine.LNX.4.64.0709021754250.6772@condmat1.ciencias.uniovi.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 24.152.192.123.res-cmts.eph.ptd.net ([24.152.192.123]:54356
	"EHLO mx.dlasys.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754137AbXIENvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 09:51:17 -0400
Received: from l-dhlii-o.dlasys.net ([206.223.20.150])
	by mx.dlasys.net with esmtp (Exim 4.67 #1 (Debian))
	id 1ISumW-0003EJ-Eg
	for <netdev@vger.kernel.org>; Wed, 05 Sep 2007 09:18:56 -0400
In-Reply-To: <Pine.LNX.4.64.0709021754250.6772@condmat1.ciencias.uniovi.es>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Igor Sobrado wrote:
>>
>> There is definite value in sharing the ath5k HAL between OpenBSD and 
>> Linux.
>
> Of course. Sharing knowledge and efforts can only improve both the GPL 
> and BSD licensed code. It is important in all cases, but becomes 
> critical when support from manufacturers is limited or even non existent.

Cooperation between OpenBSD developers and Linux developers, wwould be 
wonderful, but this appears to just be the latest of a number of 
disputes that have devolved into legalism and acrimony.

The time wasted fighting over this seems significantly larger than the 
effort need to solve it.

The respective BSD and GPL licensed code is open documentation for the 
programming of the typically closed device.
What is wrong with chosing to rewrite the drivers in contention ?
If the level of bile is sufficiently high it might make sense to do so 
using "clean room" techniques, where one developer uses the source 
licensed driver as the basis for writing documentation
and another developer uses the documentation as the basis for writing a 
new driver. The original author could/should still be credited.

It might even make sense to use projects like this as a means of 
recruiting new driver developers and building their skills - drafting 
prospective kernel developers from kernel-newbies, or asking for
volunteers on the appropriate lists.
Not having looked at the code for either the Linux or BSD atheros 
driver, but having some limited linux network driver experience, I would 
be happy to make an attempt at writing a clean Linux GPL
driver for atheros cards.

Another benefit to this approach is it might cool tempers. Neither the 
GPL not the BSD/ISC Licenses protect the information their authors have 
painstakingly extracted about the hardware.
If both sides recognize that copyright - particularly Open Source 
copyright licenses do not somehow make the ideas and information they 
express proprietary, and that all that is really
in contention is credit and a reduction in labor, then maybe it would be 
easier to get them to agree to modifying licenses.










Dave Lynch 					  	    DLA Systems
Software Development:  				         Embedded Linux
717.627.3770 	       dhlii@dlasys.net 	  http://www.dlasys.net
fax: 1.253.369.9244 			           Cell: 1.717.587.7774
Over 25 years' experience in platforms, languages, and technologies too numerous to list.

"Any intelligent fool can make things bigger and more complex... It takes a touch of genius - and a lot of courage to move in the opposite direction."
Albert Einstein

