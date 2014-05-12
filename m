From: David Newall <davidn@davidnewall.com>
Subject: Re: Bad checksum on bridge with IP options
Date: Mon, 12 May 2014 17:44:52 +0930
Message-ID: <537082FC.2030505@davidnewall.com>
References: <536F8C0F.4090206@davidnewall.com> <DUB123-W15AFD3F815E035C19E3BF9ED4A0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Lukas Tribus <luky-37@hotmail.com>, Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:39691 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685AbaELIPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 04:15:00 -0400
In-Reply-To: <DUB123-W15AFD3F815E035C19E3BF9ED4A0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/14 05:12, Lukas Tribus wrote:
> I think you will have to reproduce this on a vanilla kernel.org kernel
> like 3.14.3 and 3.15-rc5 [1] ...

Didn't know about those packages.  And to think of how much time I've 
wasted by downloading and compiling for myself...

Of course the bug does exist in a vanilla kernel, too, loaded from 
http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.14-rc8-trusty/linux-image-3.14.0-031400rc8-generic_3.14.0-031400rc8.201403242335_amd64.deb.
