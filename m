From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Tue, 08 Apr 2008 18:44:34 +0200
Message-ID: <47FBA0F2.3070605@trash.net>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Juliusz Chroboczek <jch@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44401 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbYDHQog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 12:44:36 -0400
In-Reply-To: <87skxxb8br.fsf@pirx.pps.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff -urN empty/sch_sfb.c sch_sfb/sch_sfb.c
> --- empty/sch_sfb.c	1970-01-01 01:00:00.000000000 +0100
> +++ sch_sfb/sch_sfb.c	2008-04-08 00:29:14.000000000 +0200


I wanted to review this, but the CodingStyle issues are
distracting to me, so I guess I'll wait until you've done
the cleanups suggested by Andi.

If you could make your next patch against a kernel tree
that would be also nice.

