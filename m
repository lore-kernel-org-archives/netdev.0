From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: stack smashing in iproute/ip
Date: Thu, 21 May 2015 07:19:13 -0700
Message-ID: <1432217953.4060.95.camel@edumazet-glaptop2.roam.corp.google.com>
References: <555AF73C.7050405@nokia.com>
	 <1432041939.621.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <555D8DA2.20606@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jetchko Jekov <jetchko.jekov@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:35126 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753081AbbEUOTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 10:19:15 -0400
Received: by iesa3 with SMTP id a3so9224892ies.2
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 07:19:15 -0700 (PDT)
In-Reply-To: <555D8DA2.20606@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-21 at 09:47 +0200, Jetchko Jekov wrote:


> I am confused by this reply, sorry.
> What does it mean?
> Is my fix correct one or its just workaround which doesn't fix root 
> cause of the problem?  And if is not, what would be the correct way?
> Because the current state ip command for [advanced] manipulation of GRE 
> tunnels is not so usable without proper fix.
> 

Just send an official patch. It seems you found all the reasons why code
is buggy, and how to fix it.
