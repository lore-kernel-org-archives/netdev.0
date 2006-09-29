From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 12:31:13 -0400
Message-ID: <451D4A51.4000603@hp.com>
References: <36282A1733C57546BE392885C0618592015CF2BE@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Joshua Brindle <method@gentoo.org>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:16600 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1161148AbWI2QbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 12:31:15 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C0618592015CF2BE@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala wrote:
>>I tend to agree, I just can't see it being all that useful in the real
>>world.  However, each time it comes up (including the conference call
>>earlier this week) it seems that people would prefer to use 
>>both at the
>>same time.
>  
> A matter of providing options to users.

As long as those options receive the blessings of the maintainers ;)

> It seems more of a pain to actually
> prevent their use at the same time and/or explain strange/unnatural
> behavior.

Agreed, the solution that we agreed upon is much easier to implement and
explain than a lot of the alternatives.

-- 
paul moore
linux security @ hp
