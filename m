From: David Newall <davidn@davidnewall.com>
Subject: Re: Bad checksum on bridge with IP options
Date: Mon, 12 May 2014 19:55:44 +0930
Message-ID: <5370A1A8.50604@davidnewall.com>
References: <536F8C0F.4090206@davidnewall.com> <DUB123-W15AFD3F815E035C19E3BF9ED4A0@phx.gbl>,<537082FC.2030505@davidnewall.com> <DUB123-W6BB791EB7730D01668FA4ED350@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Lukas Tribus <luky-37@hotmail.com>, Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:40614 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804AbaELKZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 06:25:47 -0400
In-Reply-To: <DUB123-W6BB791EB7730D01668FA4ED350@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/14 19:45, Lukas Tribus wrote:
> 3.15-rc5 is the kernel you should test.

3.14-rc8 was the latest build with 14.04 configuration.  It's a vanilla 
kernel and I don't suppose it's so old that anyone would be unsure about 
a change which might have fixed the problem since then.

This is a bug.  Let's not stand on ceremony.  Let's fix it.
