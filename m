From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: skge crashes
Date: Wed, 16 Aug 2006 23:54:05 +0200
Message-ID: <664E3671B2B6DC439E0C9FFCF8E40CA205F501@exchange.I-BNEX>
References: <20060816105752.717c3d86@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Krzysztof Oledzki" <olel@ans.pl>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from loewe.unit-netz.de ([212.202.148.42]:32949 "EHLO
	loewe.unit-netz.de") by vger.kernel.org with ESMTP id S932271AbWHPVyR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 17:54:17 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20060816105752.717c3d86@localhost.localdomain>
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Stephen,
>> 
>> the reproducible crashes with all skge versions (where sk98lin works
>> fine) on my box are SMP related.
>> I booted with maxcpus=1 and the box survived my usual crash test, I will
>> keep an eye.
>> 
>> Daniel
>> 

> Is this P3 SMP?
> What form of IRQ balance are you using?

Indeed, P3 SMP and the kernel balancer.
