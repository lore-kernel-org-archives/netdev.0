From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH-2.6.26] rndis_host: fix oops when query for
	OID_GEN_PHYSICAL_MEDIUM fails
Date: Sat, 22 Mar 2008 13:14:37 +0200
Message-ID: <20080322131437.gb7triy40sgg4o80@hayate.ip6>
References: <20080317213301.15070.30388.stgit@fate.lan>
	<200803171442.11529.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn2.hy.skanova.net ([81.228.8.154]:33938 "EHLO
	pne-smtpout4-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753800AbYCVLOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 07:14:41 -0400
In-Reply-To: <200803171442.11529.david-b@pacbell.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting David Brownell <david-b@pacbell.net>:

> ... this should be for 2.6.25 though, yes?  Since that
> change was introduced after 2.6.24, and this would
> otherwise cause a regression ...

Should I resend patch? It hasn't got into 2.6.25 yet. Actually, who am  
I supposed to CC bugfix patches?


