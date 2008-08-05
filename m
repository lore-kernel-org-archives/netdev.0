From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ipv4: remove unused field in struct flowi
 (include/net/flow.h).
Date: Tue, 05 Aug 2008 01:20:00 -0700 (PDT)
Message-ID: <20080805.012000.125464852.davem@davemloft.net>
References: <eb3ff54b0808050114xf95cca1kab4971f6f9bd4103@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47004
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754693AbYHEIT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 04:19:59 -0400
In-Reply-To: <eb3ff54b0808050114xf95cca1kab4971f6f9bd4103@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Tue, 5 Aug 2008 11:14:02 +0300

> This patch removes an unused field (flags) from struct flowi;
> it seems that this "flags" field was used once in the past for
> multipath routing with
> FLOWI_FLAG_MULTIPATHOLDROUTE flag  (which does no longer exist);
> however, the "flags"
> field of struct flowi is not used anymore.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks a lot Rami.
