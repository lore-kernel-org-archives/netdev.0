From: Ray Lee <ray-lk@madrabbit.org>
Subject: Re: ieee80211 sleeping in invalid context
Date: Tue, 12 Dec 2006 09:51:26 -0800
Message-ID: <457EEC1E.9000806@madrabbit.org>
References: <455B63EC.8070704@madrabbit.org> <455F58AC.3030801@lwfinger.net> <457E2AE2.1020108@madrabbit.org> <200612121014.30309.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from tapsys.com ([72.36.178.242]:34726 "EHLO tapsys.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932281AbWLLRvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Dec 2006 12:51:35 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200612121014.30309.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> Congratulations to your decision ;)

Sometimes making decisions via Brownian motion has its advantages.

> Which kernel are you using?

Hmm, I'm using the mercurial repository, let me see if I can translate that to a git
head... Looks like git tree c2bb88baa52429b6b76e3ba4272cb2b29713c5a8 . (Which is from
less than 24 hours ago.)

> There is some locking breakage in latest kernels with softmac.
> I attached the fixes for the known bugs.

Okay, I'll apply to my local copy, rebuild, and try again. I'll let you know what
happens.

Ray
