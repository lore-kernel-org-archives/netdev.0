From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH] [XFRM] IPv6: Fix dst/routing check at transformation.
Date: Fri, 21 Dec 2007 14:06:53 +0900
Message-ID: <200712211406.53583.nakam@linux-ipv6.org>
References: <11982084391595-git-send-email-nakam@linux-ipv6.org> <200712211248.31508.nakam@linux-ipv6.org> <20071220.195054.23654691.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:48348 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750695AbXLUFG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 00:06:57 -0500
In-Reply-To: <20071220.195054.23654691.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Friday 21 December 2007 12:50, David Miller wrote:
> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Date: Fri, 21 Dec 2007 12:48:31 +0900
> 
> > My 5 patches for XFRM sent to netdev should be TOed to David, but it is not.
> > 
> > It does not seems that the command works for me.
> > git-send-email --to "David S. Miller <davem@davemloft.net>" --to herbert@gondor.apana.org.au --cc...
> > 
> > Please see my patches, even it is not TOed to you.
> 
> All of your patches won't make it anywhere.
> 
> In the email headers my name shows up like this:
> 
> 	David S. Miller
> 
> Email SMTP rules dictate that if special characters like
> "." appear in the name it must be surrounded by double
> quotes otherwise it is a syntax error.
> 
> This is a bug in git-send-email that I thought was fixed
> by now.  Perhaps it is fixed in git mainline and not any
> of the stable releases yet.
> 
> Perhaps you can submit them by hand until you resolve the
> git-send-email problem?

Thanks, I'll resend by hand this time.
Mayby I use your e-mail address without name
by current git-send-email.

-- 
Masahide NAKAMURA
