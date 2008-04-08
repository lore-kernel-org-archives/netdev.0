From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Tue, 08 Apr 2008 02:04:24 +0200
Message-ID: <47FAB688.7010807@trash.net>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Juliusz Chroboczek <jch@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51167 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754165AbYDHAHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 20:07:19 -0400
In-Reply-To: <87skxxb8br.fsf@pirx.pps.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Juliusz Chroboczek wrote:
> Hello,
>
> The attached is an implementation of the Stochastic Fair Blue queue
> discipline for Linux.
>
> I would like to request a review of the following code, and whether it
> is worthwile to add the Kconfig bits and submit it for inclusion into
> the mainline kernel.
>
> You will find a ready to build tarball on
>
>   http://www.pps.jussieu.fr/~jch/software/files/sch_sfb-20080407.tar.gz
>   http://www.pps.jussieu.fr/~jch/software/files/sch_sfb-20080407.tar.gz.asc
>
> and a short description on
>
>   http://www.pps.jussieu.fr/~jch/software/sfb/

Do you have some graphs or something showing the effects?
I experienced with SFB myself some time ago and recall
getting huge unfairness towards non-ECN connections.
I can't remember exactly how good it behaved overall.


