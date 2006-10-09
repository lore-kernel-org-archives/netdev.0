From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 0/3] Fix for IPsec leakage with SELinux enabled - V.03
Date: Mon, 9 Oct 2006 11:42:18 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CFD4D@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov, eparis@redhat.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:46459 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932950AbWJIPmt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 11:42:49 -0400
To: David Miller <davem@davemloft.net>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > My apologies. The second one is also numbered 1, but has the
> > following distinct subject line:
> > [PATCH 1/3] Fix for IPsec leakage with SELinux enabled - 
> V.03: Fix xfrm code
> 
> I definitely deleted one of them, since I usually get N copies
> of very single patch posting and two of them looked identical:)

I guess this is probably the reason why I don't see the fix in net-2.6.git
yet :) I will resend the patchset with the subject titles fixed up since
it needs to be in 2.6.19.
