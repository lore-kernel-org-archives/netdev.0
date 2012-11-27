From: Chris Wilson <chris@aptivate.org>
Subject: Re: [PATCH 1/1] Introduce notification events for routing changes
Date: Tue, 27 Nov 2012 20:32:05 +0000 (GMT)
Message-ID: <alpine.DEB.2.00.1211272031030.17417@chris-desktop.fen.aptivate.org>
References: <1354048045-17846-1-git-send-email-kadlec@blackhole.kfki.hu> <1354048045-17846-2-git-send-email-kadlec@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one-mail.aptivate.org ([87.106.150.205]:53399 "EHLO
	one-mail.aptivate.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755381Ab2K0UbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 15:31:07 -0500
In-Reply-To: <1354048045-17846-2-git-send-email-kadlec@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joszef,

On Tue, 27 Nov 2012, Jozsef Kadlecsik wrote:

> The netfilter MASQUERADE target does not handle the case when the routing
> changes and the source address of existing connections become invalid.
> The problem can be solved if routing modifications create events to which
> the MASQUERADE target can subscribe and then delete the affected
> connections.

I would like to thank you personally for picking this up and running with 
it, developing the patches and pushing for their inclusion. Thank you. 
Your hard work is very much appreciated here.

Cheers, Chris.
-- 
Aptivate | http://www.aptivate.org | Phone: +44 1223 967 838
Future Business, Cam City FC, Milton Rd, Cambridge, CB4 1UY, UK

Aptivate is a not-for-profit company registered in England and Wales
with company number 04980791.
