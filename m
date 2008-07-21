From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 10:28:52 -0700 (PDT)
Message-ID: <20080721.102852.124418551.davem@davemloft.net>
References: <4883E465.4050405@trash.net>
	<Xine.LNX.4.64.0807212143540.17349@us.intercode.com.au>
	<48847BA5.2020600@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58818
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751016AbYGUR2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 13:28:52 -0400
In-Reply-To: <48847BA5.2020600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 21 Jul 2008 14:05:57 +0200

> The idea was that NETFILTER_ADVANCED=n enables everything needed
> by mainstream distributions and hides the rest. We can certainly
> change the default for this option, but that makes NETFILTER_ADVANCED
> pretty much useless.

A new feature cannot possibly be used by existing distributions.  I
think that's the main gripe.

Distributions themselves will enable the feature no matter what we
mark it's default as.

And once the feature thus becomes pervasive we can re-adjust the
default.
