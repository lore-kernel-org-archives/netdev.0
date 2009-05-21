From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Thu, 21 May 2009 10:51:17 +0200
Message-ID: <20090521085116.GC2892@ami.dom.local>
References: <20090517201528.GA8552@ami.dom.local> <20090518065629.GA6006@ff.dom.local> <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com> <298f5c050905181016w552b283q2bb2ec508433525a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:55045 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbZEUIwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 04:52:33 -0400
Received: by bwz22 with SMTP id 22so874608bwz.37
        for <netdev@vger.kernel.org>; Thu, 21 May 2009 01:52:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <298f5c050905181016w552b283q2bb2ec508433525a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2009 at 06:16:26PM +0100, Antonio Almeida wrote:
> I forgot to tell you that I used tc source code from iproute2-2.6.16.
> I couldn't use the newest version because I got errors when compiling.

I still have no clue about the reason, but it would be really nice to
do some short test with more current kernel (>= 2.6.27) and iproute2
(to exclude the possibility of some incomaptibility in configs e.g.
rate tables passed to htb).

Thanks,
Jarek P.
