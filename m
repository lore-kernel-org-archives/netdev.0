From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 08 May 2007 19:31:26 +0200
Message-ID: <4640B3EE.1020707@wpkg.org>
References: <464034CF.20700@wpkg.org>	<f19298770705080148u70638ac2ue87241382681088@mail.gmail.com>	<m3bqgv72sq.fsf@maximus.localdomain>	<20070508155201.GA1251@xi.wantstofly.org> <m3hcqn5j0p.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michael Jones <mlj28@cam.ac.uk>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.syneticon.net ([213.239.212.131]:41911 "EHLO
	mail2.syneticon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965337AbXEHRct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 13:32:49 -0400
In-Reply-To: <m3hcqn5j0p.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Halasa schrieb:
> Lennert Buytenhek <buytenh@wantstofly.org> writes:
> 
>> There _is_ an ARM BE version of Debian.
>>
>> It's not an official port, but it's not maintained any worse than
>> the 'official' LE ARM Debian port is.
> 
> Hmm... That changes a bit. Perhaps we should forget about
> that LE thing then, and (at best) put that trivial workaround?

Does using ixp4xx on LE have any other drawbacks than inferior network 
performance?

And talking about network performance, what numbers are we talking about 
(LE vs BE; 30% performance hit on LE, more, or less)?


-- 
Tomasz Chmielewski
http://wpkg.org
