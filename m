From: Jeremy Kerr <jk@ozlabs.org>
Subject: Re: [PATCH] sctp: rfc conformance fixes
Date: Thu, 23 Oct 2008 14:34:47 +1100
Message-ID: <200810231434.47989.jk@ozlabs.org>
References: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com> <48FFBA06.50609@hp.com> <200810231143.22027.jk@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	patchwork@ozlabs.org, Maxime Bizon <mbizon@freebox.fr>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41454 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086AbYJWDib (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 23:38:31 -0400
In-Reply-To: <200810231143.22027.jk@ozlabs.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David. Maxime & Vlad,

> Looks like the email is fine, I'll see what's happening on the
> patchwork side.

OK, patchwork didn't like that the mail had no Content-Type header, so 
has no character set encoding defined. I've just checked-in change to 
assume a utf-8 encoding by default:

http://git.ozlabs.org/?p=patchwork;a=commitdiff;h=d45218b2e3894211e11313820bea9f59677c4bf2

Which should mean that future patches will be accepted.

(if you'd like me to manually re-inject that series of patches, just 
forward the mboxes over to me)

Cheers,


Jeremy

 

