From: Helge Hafting <helge.hafting@aitel.hist.no>
Subject: Re: 2.6.17: networking bug??
Date: Mon, 19 Jun 2006 09:07:02 +0200
Message-ID: <44964D16.6060206@aitel.hist.no>
References: <Pine.LNX.4.64.0606131048550.5498@g5.osdl.org>	<448F0344.9000008@rtr.ca>	<448F0D4B.30201@rtr.ca> <20060613.142603.48825062.davem@davemloft.net> <448F32E1.8080002@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jheffner@psc.edu,
	torvalds@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from embla.aitel.hist.no ([158.38.50.22]:16057 "HELO
	embla.aitel.hist.no") by vger.kernel.org with SMTP id S1751216AbWFSHKa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 03:10:30 -0400
To: Mark Lord <lkml@rtr.ca>
In-Reply-To: <448F32E1.8080002@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Lord wrote:
>
> Unilaterally following the standard is all well and good
> for those who know how to get around it when a site becomes
> inaccessible, but not for Joe User.
>
So lets enable it in the kernel, and let the distros turn it off.
The Joe User who isn't a kernel hacker won't be running 2.6.17
in a long time.  He'll be running whatever his distro packages for him,
and they will know how to disable (or patch out) window scaling.

Someone who compiles his own kernel runs into all sorts of
issues, this is just one more of them.
> If it always fails, or always works, that's not such a big problem.
> I would never have complained if I had never been able to access
> the web sites in question.  But since it IS working in 2.6.16,
> and got broken in 2.6.17, I'm bloody well going to complain.
Yes.  And make sure you complain to those running the bad
box as well.

Helge Hafting
