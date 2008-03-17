From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH-2.6.26] rndis_host: fix oops when query for
	OID_GEN_PHYSICAL_MEDIUM fails
Date: Tue, 18 Mar 2008 00:02:31 +0200
Message-ID: <20080318000231.4kx2rr3x0gksoswc@hayate.ip6>
References: <20080317213301.15070.30388.stgit@fate.lan>
	<200803171442.11529.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: dmonakhov@openvz.org, netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout3-sn1.fre.skanova.net ([81.228.11.120]:38062 "EHLO
	pne-smtpout3-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753314AbYCQWCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 18:02:36 -0400
In-Reply-To: <200803171442.11529.david-b@pacbell.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting David Brownell <david-b@pacbell.net>:

> ... this should be for 2.6.25 though, yes?  Since that
> change was introduced after 2.6.24, and this would
> otherwise cause a regression ...
>

Yes, that's right. Just after hitting enter on 'stg mail', I oops'd.


