From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 02/27] drivers/net: fix sparse warnings: make do-while a compound statement
Date: Thu, 25 Dec 2008 18:02:44 +0100
Message-ID: <m3iqp89oi3.fsf@maximus.localdomain>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191507.11807.50794.stgit@vmbox.hanneseder.net>
	<m3hc4voo2a.fsf@maximus.localdomain>
	<a01a16b50812221544x45c3559ap808ac0095ee8f01@mail.gmail.com>
	<m3ocz2ua3w.fsf@maximus.localdomain> <1230053186.1447.9.camel@brick>
	<m3k59qssix.fsf@maximus.localdomain>
	<alpine.LFD.2.00.0812231008350.3535@localhost.localdomain>
	<m3hc4usco9.fsf@maximus.localdomain>
	<alpine.LFD.2.00.0812231529030.3535@localhost.localdomain>
	<m3myemqqgp.fsf@maximus.localdomain>
	<alpine.LFD.2.00.0812231808030.3535@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harvey Harrison <harvey.harrison@gmail.com>,
	=?utf-8?B?SMOla29uIEzDuHZkYWw=?= <hlovdal@gmail.com>,
	Hannes Eder <hannes@hanneseder.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:40087 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595AbYLYRCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Dec 2008 12:02:47 -0500
In-Reply-To: <alpine.LFD.2.00.0812231808030.3535@localhost.localdomain> (Linus Torvalds's message of "Tue\, 23 Dec 2008 18\:10\:27 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> Anyway,  not worth discussing. The fact is, the kernel does not accept do 
> while without braces. I told you why. You can ignore it. I'll ignore you.

Oh, I'm not a martyr.
-- 
Krzysztof Halasa
