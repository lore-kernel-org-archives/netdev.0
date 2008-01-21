From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 2/3][NET] gen_estimator: list_empty() check in
	est_timer() fixed
Date: Mon, 21 Jan 2008 15:43:33 +0100
Message-ID: <20080121144333.GI1789@ff.dom.local>
References: <20080121064240.GB981@ff.dom.local> <20080121.023632.122420355.davem@davemloft.net> <20080121111940.GF1789@ff.dom.local> <20080121.031553.224463409.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, slavon@bigtelecom.ru,
	kaber@trash.net, hadi@cyberus.ca, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:16982 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389AbYAUOhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 09:37:07 -0500
Received: by ug-out-1314.google.com with SMTP id z38so884029ugc.16
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2008 06:37:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080121.031553.224463409.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2008 at 03:15:53AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 21 Jan 2008 12:19:40 +0100
> 
> > On Mon, Jan 21, 2008 at 02:36:32AM -0800, David Miller wrote:
> > ...
> > > FWIW I agree that double-negatives are confusing and we should
> > > avoid them.
> > 
> > Right! No more: CHECKSUM_NONE, SOCK_NOSPACE, IFF_NOARP or KERN_NOTICE!
> 
> Life is difficult sometimes, but that is no excuse to further
> the pain :-)

BTW, maybe somebody else finds this interesting (because you seem to
know this very well), in some languages, like Polish, e.g.: "that is
no excuse" needs double-negative: "to nie jest zadne wytlumaczenie",
so literally: "that not is no excuse"...

Cheers,
Jarek P.
