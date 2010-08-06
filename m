From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.9
Date: Fri, 06 Aug 2010 15:15:15 +0200
Message-ID: <4C5C0AE3.4090806@trash.net>
References: <4C5832F9.50004@trash.net> <x6bp9jy7sj@gzp> <4C584C63.8010607@trash.net> <x6vd7rwrah@gzp> <x6lj8nwqu4@gzp> <alpine.LSU.2.01.1008032001430.1519@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Gabor Z. Papp" <gzp@papp.hu>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43950 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251Ab0HFNPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 09:15:23 -0400
In-Reply-To: <alpine.LSU.2.01.1008032001430.1519@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 03.08.2010 20:04, schrieb Jan Engelhardt:
> The following changes since commit 371cea299f0b2eb100b9fc9fb99089640d2d606f:
> 
>   xtables: remove unnecessary cast (2010-08-03 19:56:11 +0200)
> 
> are available in the git repository at:
>   git://dev.medozas.de/iptables master
> 
> Jan Engelhardt (1):
>       build: fix static linking
> 
>  extensions/libxt_IDLETIMER.c |    2 +-
>  extensions/libxt_TEE.c       |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> [Actually there's also the "remove unnecessary cast" patch that is not 
> included in this listing, but merging that should be ok.]

Pulled, thanks Jan.
