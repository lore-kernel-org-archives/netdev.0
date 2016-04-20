From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Regression in next for smsc911x with tigthen lockdep checks
Date: Wed, 20 Apr 2016 17:22:49 +0200
Message-ID: <57179EC9.6000505@stressinduktion.org>
References: <20160420150108.GF5995@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org
To: Tony Lindgren <tony@atomide.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:46145 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751949AbcDTPWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 11:22:51 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 9F22220856
	for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 11:22:50 -0400 (EDT)
In-Reply-To: <20160420150108.GF5995@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 20.04.2016 17:01, Tony Lindgren wrote:
> Looks like commit fafc4e1ea1a4 ("sock: tigthen lockdep checks for
> sock_owned_by_user") in next causes a regression at least for
> smsc911x with CONFIG_LOCKDEP. It keeps spamming with the following
> message. Any ideas?

Not yet, can you quickly send me your config?

Thanks,
Hannes
