From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Fix for IPsec leakage with SELinux enabled - V.03
Date: Thu, 05 Oct 2006 14:05:05 -0700 (PDT)
Message-ID: <20061005.140505.21926017.davem@davemloft.net>
References: <45256E25.6020201@trustedcs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov, eparis@redhat.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:65450
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751352AbWJEVFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 17:05:04 -0400
To: vyekkirala@trustedcs.com
In-Reply-To: <45256E25.6020201@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Date: Thu, 05 Oct 2006 15:42:13 -0500

> This version takes into account David Miller's comments
> regarding treatment of security layer errors in the case
> of socket policies. Specifically, these errors will be
> treated like how these kind of errors are treated for
> the main/sub policies, which is to return a full lookup
> failure.

I only have patches "1" and "3" in my inbox, did you forget
to send the second one out or are they simply misnumbered?
