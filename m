From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_packet: use define instead of constant
Date: Wed, 22 Aug 2012 22:58:54 -0700 (PDT)
Message-ID: <20120822.225854.727423592838519850.davem@davemloft.net>
References: <1345469643.22726.2.camel@thinkbox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: danborkmann@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33457 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755088Ab2HWF6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 01:58:55 -0400
In-Reply-To: <1345469643.22726.2.camel@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <danborkmann@iogearbox.net>
Date: Mon, 20 Aug 2012 15:34:03 +0200

> Instead of using a hard-coded value for the status variable, it would make
> the code more readable to use its destined define from linux/if_packet.h.
> 
> Signed-off-by: daniel.borkmann@tik.ee.ethz.ch

Applied.
