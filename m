From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] be2net: fix multicast filter programming
 Multicast programming has been broken since commit 5b8821b7. Setting the
 MULTICAST flag while sending the cmd to the FW was missing. Fixed this.
Date: Tue, 27 Sep 2011 13:28:41 -0400 (EDT)
Message-ID: <20110927.132841.1875325457381063135.davem@davemloft.net>
References: <1317122035-5533-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab1I0R2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 13:28:46 -0400
In-Reply-To: <1317122035-5533-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 27 Sep 2011 16:43:54 +0530

> Also fixed-up some indentation in the adjacent lines.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Please don't create multi-line subjects, condense the subject into something that fits on
one 80-character line then put the details in the body of the commit message..
