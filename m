From: Florian Zumbiehl <florz@florz.de>
Subject: Re: [PATCH 4/4] PPPoE: race between interface going down and release()
Date: Sat, 21 Apr 2007 01:44:05 +0200
Message-ID: <20070420234405.GB25618@florz.florz.dyndns.org>
References: <20070311044143.GD17712@florz.florz.dyndns.org> <1173667016.24373.36.camel@kdsk1.austin.ibm.com> <20070420.162756.78644819.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mostrows@earthlink.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [77.10.163.159] ([77.10.163.159]:2471 "EHLO
	rain.florz.dyndns.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752834AbXDUAGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 20:06:43 -0400
Content-Disposition: inline
In-Reply-To: <20070420.162756.78644819.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> This patch doesn't apply becuase in the actual pppoe.c code:

[...]

> So I'm having trouble figuring out what tree you generated
> that patch against :-)  Perhaps there was an earlier patch
> I missed or something.
> 
> But I won't second guess and leave it to you to let me know
> what I should actually apply.

That one was against my first try of a fix. So, either you apply that
one first and then remove it again by applying that patch ;-) - or just
ignore those four patches completely and apply
<11737949753580-git-send-email-mostrows@earthlink.net> ff instead.

Florian
