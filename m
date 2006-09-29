From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 12:27:56 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF2BE@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	Joshua Brindle <method@gentoo.org>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:28971 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161137AbWI2Q2N
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:28:13 -0400
To: Paul Moore <paul.moore@hp.com>, James Morris <jmorris@namei.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I tend to agree, I just can't see it being all that useful in the real
> world.  However, each time it comes up (including the conference call
> earlier this week) it seems that people would prefer to use 
> both at the
> same time.

A matter of providing options to users. It seems more of a pain to actually
prevent their use at the same time and/or explain strange/unnatural
behavior.
