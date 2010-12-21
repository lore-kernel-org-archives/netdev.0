From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] sch_sfq: allow big packets and be fair
Date: Tue, 21 Dec 2010 10:30:26 +0000
Message-ID: <20101221103026.GA8622@ff.dom.local>
References: <1292886976.2627.146.camel@edumazet-laptop> <20101221101506.GA8149@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:33442 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933754Ab0LUKd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 05:33:29 -0500
Received: by fxm18 with SMTP id 18so4125378fxm.2
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 02:33:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20101221101506.GA8149@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 21, 2010 at 10:15:06AM +0000, Jarek Poplawski wrote:
> The change of allotment limit looks OK [...]

Hmm... but maybe s/ALLOT_ZERO/SFQ_ALLOT_ZERO/? ;-)

Jarek P.
