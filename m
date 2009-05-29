From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: SiS 191 failure with MTU > 1496
Date: Sat, 30 May 2009 00:30:47 +0200
Message-ID: <20090529223047.GA29073@electric-eye.fr.zoreil.com>
References: <1243615486.12871.44.camel@plop> <1243615800.12871.45.camel@plop> <1243616449.12871.49.camel@plop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pascal Terjan <pterjan@mandriva.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35443 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752075AbZE2W3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 18:29:36 -0400
Content-Disposition: inline
In-Reply-To: <1243616449.12871.49.camel@plop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pascal Terjan <pterjan@mandriva.com> :
[...]
> Oh and even
> http://bugzilla.kernel.org/show_bug.cgi?id=10694

Yes, it sucks.

> Should I add some info there ?

Not yet but could you retry with RX_BUF_SIZE set to 1544,
1528 and 1520 ?

-- 
Ueimor
