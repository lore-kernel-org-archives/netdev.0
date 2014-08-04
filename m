From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [PATCH] batman-adv: Fix out-of-order fragmentation support
Date: Mon, 04 Aug 2014 18:26:32 +0200
Message-ID: <5564567.83o54DtWyR@bentobox>
References: <1407167221-10575-1-git-send-email-antonio@meshcoding.com> <1407167221-10575-2-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:51628 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750831AbaHDQfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2014 12:35:46 -0400
In-Reply-To: <1407167221-10575-2-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 04 August 2014 17:47:01 Antonio Quartulli wrote:
> This problem was introduced in 9b3eab61754d74a93c9840c296013fe3b4a1b606
> ("batman-adv: Receive fragmented packets and merge").

This is not a commit id from the kernel tree but the one from your out-of-tree 
repository at http://git.open-mesh.org/batman-adv.git . 
610bfc6bc99bc83680d190ebc69359a05fc7f605 seems to be the one of Martin's 
commit when it was applied in the kernel repository.

Kind regards,
	Sven
