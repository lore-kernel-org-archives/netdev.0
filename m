From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 5/7] atm: [br2864] fix routed vcmux support
Date: Mon, 16 Jun 2008 17:20:12 -0700 (PDT)
Message-ID: <20080616.172012.03949802.davem@davemloft.net>
References: <200806161727.m5GHRfNh003377@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35639
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752917AbYFQAUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 20:20:12 -0400
In-Reply-To: <200806161727.m5GHRfNh003377@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Mon, 16 Jun 2008 13:27:41 -0400

>     atm: [br2864] fix routed vcmux support
>     
>     From: Eric Kinzie <ekinzie@cmf.nrl.navy.mil>
>     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

Applied.

But please provide more detailed commit messages, this one leaves a
lot to be desired.

What was broken about vcmux support and what was the top-level scheme
used to fix that problem?

Not many people other than the author of the patch knows the answer to
those questions because this commit message is opaque.  If someone
has to come across this commit to try and diagnose something, they
will be pretty lost as to what was the intent here.

