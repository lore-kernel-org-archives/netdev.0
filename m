From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [patch sungem] improved locking
Date: Tue, 12 Dec 2006 16:36:23 +1100
Message-ID: <1165901783.11914.36.camel@localhost.localdomain>
References: <5cac192f0611141354l3a4aa130ve741c9d6a7a49d0a@mail.gmail.com>
	 <20061128.144911.55733883.davem@davemloft.net>
	 <5cac192f0611290256l7067ce21r39881486f6e21289@mail.gmail.com>
	 <20061211.174351.104064300.davem@davemloft.net>
	 <5cac192f0612112133p71966d8bt51e98fecabc312d5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33629 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751177AbWLLFge (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Dec 2006 00:36:34 -0500
To: Eric Lemoine <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f0612112133p71966d8bt51e98fecabc312d5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-12-12 at 06:33 +0100, Eric Lemoine wrote:
> On 12/12/06, David Miller <davem@davemloft.net> wrote:
> > [...]
> > Anyways, Eric your changes look fine as far as I can tell, can you
> > give them a really good testing on some SMP boxes?
> 
> Unfortunately I can't, I don't have the hardware (only an old ibook here).

I do however, I'll give it a beating on a dual G5 as soon as I get a
chance. I'm pretty swamped at the moment and the box is used by somebody
else today.

Ben.


