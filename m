From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Wed, 23 Jul 2008 16:42:56 -0700 (PDT)
Message-ID: <20080723.164256.261160675.davem@davemloft.net>
References: <20080721.102852.124418551.davem@davemloft.net>
	<alpine.LFD.1.10.0807211037200.31863@woody.linux-foundation.org>
	<4884F28E.6040903@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, jmorris@namei.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44492
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752146AbYGWXm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 19:42:56 -0400
In-Reply-To: <4884F28E.6040903@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 21 Jul 2008 22:33:18 +0200

> Its not needed today of course, so the attached patch changes it
> to depend on NETFILTER_ADVANCED and removes the default.

I've applied this, thanks Patrick.
