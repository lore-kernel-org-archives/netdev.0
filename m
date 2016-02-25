From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/10] bnxt_en: Improve bnxt_vf_update_mac().
Date: Thu, 25 Feb 2016 14:02:53 -0500 (EST)
Message-ID: <20160225.140253.1775475019446000397.davem@davemloft.net>
References: <CACKFLi=ycecx03nPAUzVPG8-v8tvPEC5iXUtpwibVkAxhwdzMg@mail.gmail.com>
	<20160225.120921.2096022701010736406.davem@davemloft.net>
	<CACKFLik3f0ca4cnzMK1-H_qjF92GjA43cV-8ZBb018na97jZhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933286AbcBYTC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 14:02:58 -0500
In-Reply-To: <CACKFLik3f0ca4cnzMK1-H_qjF92GjA43cV-8ZBb018na97jZhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Thu, 25 Feb 2016 09:15:39 -0800

> I agree it is complicated.  The default, if nobody does anything, is random
> MAC.  But random MAC has disadvantages, so we allow some options
> for the PF or VF users to change it.

Ok, thanks for explaining.
