From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 3/5] can: af_can.c use rcu_barrier() on module unload.
Date: Wed, 10 Jun 2009 10:22:10 +0200
Message-ID: <4A2F6D32.8030400@hartkopp.net>
References: <20090608130959.10052.54590.stgit@localhost>	<20090608131138.10052.5408.stgit@localhost>	<4A2D112A.4000308@hartkopp.net> <20090610.011027.43904351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: patchwork@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:10882 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213AbZFJIWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 04:22:11 -0400
In-Reply-To: <20090610.011027.43904351.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Oliver Hartkopp <oliver@hartkopp.net>
> Date: Mon, 08 Jun 2009 15:24:58 +0200
> 
>> Acked-By: Oliver Hartkopp <oliver@hartkopp.net>
> 
> Please don't capitalize the "By" in "Acked-By".

Sorry.

> Otherwise
> patchwork doesn't pick them up automatically.

IMHO patchwork should be robust against these type of typos and convert them
for the users (== your) convenience into 'Acked-by:' ...

Regards,
Oliver

