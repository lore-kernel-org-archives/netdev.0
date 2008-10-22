From: Jeremy Kerr <jk@ozlabs.org>
Subject: Re: [PATCH] sctp: rfc conformance fixes
Date: Wed, 22 Oct 2008 16:35:09 +1100
Message-ID: <200810221635.10268.jk@ozlabs.org>
References: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com> <200810221601.27588.jk@ozlabs.org> <1224653529.6597.40.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:55779 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbYJVFhj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 01:37:39 -0400
In-Reply-To: <1224653529.6597.40.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Maxime,

> I sent a patch sunday (using git-format-patch/git-send-email), and
> patchwork seems to have missed it, I can't see it even with all
> filters removed.

There are some conditions where the parser will reject the patch 
outright, usually due to character encoding breakages (either in the 
email itself or the parser code).

If you could send me an mbox file containing the email, I'll see what's 
going on (and add a testcase to patchwork).

Cheers,


Jeremy
