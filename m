From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [XFRM] IPv6: Fix dst/routing check at transformation.
Date: Thu, 20 Dec 2007 19:50:54 -0800 (PST)
Message-ID: <20071220.195054.23654691.davem@davemloft.net>
References: <11982084391595-git-send-email-nakam@linux-ipv6.org>
	<200712211248.31508.nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33628
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760726AbXLUDuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 22:50:55 -0500
In-Reply-To: <200712211248.31508.nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Fri, 21 Dec 2007 12:48:31 +0900

> My 5 patches for XFRM sent to netdev should be TOed to David, but it is not.
> 
> It does not seems that the command works for me.
> git-send-email --to "David S. Miller <davem@davemloft.net>" --to herbert@gondor.apana.org.au --cc...
> 
> Please see my patches, even it is not TOed to you.

All of your patches won't make it anywhere.

In the email headers my name shows up like this:

	David S. Miller

Email SMTP rules dictate that if special characters like
"." appear in the name it must be surrounded by double
quotes otherwise it is a syntax error.

This is a bug in git-send-email that I thought was fixed
by now.  Perhaps it is fixed in git mainline and not any
of the stable releases yet.

Perhaps you can submit them by hand until you resolve the
git-send-email problem?

Thanks.
