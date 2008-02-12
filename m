From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][AX25] ax25_route: make ax25_route_lock BH safe
Date: Tue, 12 Feb 2008 09:44:55 +0000
Message-ID: <20080212094455.GC2582@ff.dom.local>
References: <000d01c86c8b$fd9e67d0$453c822c@dg8ngn> <20080211124251.GB3597@ff.dom.local> <000201c86d53$569297e0$453c822c@dg8ngn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'David Miller' <davem@davemloft.net>,
	'Bernard Pidoux F6BVP' <f6bvp@free.fr>,
	'Ralf Baechle DL5RB' <ralf@linux-mips.org>,
	netdev@vger.kernel.org
To: Jann Traschewski <jann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:61374 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755750AbYBLJhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 04:37:43 -0500
Received: by nf-out-0910.google.com with SMTP id g13so1364933nfb.21
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2008 01:37:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <000201c86d53$569297e0$453c822c@dg8ngn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 12, 2008 at 09:43:26AM +0100, Jann Traschewski wrote:
> Applied on 2.6.24.2 and up without any problems/warnings since 12 hours.
> Thanks,
> Jann

Thanks Jann, too!

BTW, I hope maybe until tomorrow I'll figure out something about those
earlier two AX25 testing patches.

Regards,
Jarek P.
