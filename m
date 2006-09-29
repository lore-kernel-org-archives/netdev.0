From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 12:50:32 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609291247170.6007@d.namei>
References: <36282A1733C57546BE392885C0618592015CF2BE@chaos.tcs.tcs-sec.com>
 <451D4A51.4000603@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Joshua Brindle <method@gentoo.org>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:31469 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932357AbWI2Que (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:50:34 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <451D4A51.4000603@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Sep 2006, Paul Moore wrote:

> > It seems more of a pain to actually
> > prevent their use at the same time and/or explain strange/unnatural
> > behavior.
> 
> Agreed, the solution that we agreed upon is much easier to implement and
> explain than a lot of the alternatives.

Ok, can you please explain it further?

i.e. show me what the policy looks like, exactly what the user is trying 
to achieve, and explain what happens to each packet exactly in terms of 
labeling on the input and output paths.




-- 
James Morris
<jmorris@namei.org>
