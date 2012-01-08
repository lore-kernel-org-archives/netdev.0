From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/7] via-rhine: factor out tx_thresh handling
Date: Sun, 8 Jan 2012 10:39:06 +0100
Message-ID: <20120108093906.GA28125@electric-eye.fr.zoreil.com>
References: <20120107224856.GA24928@electric-eye.fr.zoreil.com> <20120107224941.GA25021@electric-eye.fr.zoreil.com> <CACPM=kVKm1xYnBGJ_-ABaBkLcSApnixagQhqmgi89OfCTn5ktQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rl@hellgate.ch,
	David Miller <davem@davemloft.net>
To: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52979 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850Ab2AHJsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2012 04:48:36 -0500
Content-Disposition: inline
In-Reply-To: <CACPM=kVKm1xYnBGJ_-ABaBkLcSApnixagQhqmgi89OfCTn5ktQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
[...]
> Still net-next, or should they be applied on top of mainline 3.2? :)

The base commit is common to davem-next and linus branches. It is an
ancestor of davem's stable branch as well. The patch should thus apply
everywhere the same and rebase automagically... for some time.

-- 
Ueimor
