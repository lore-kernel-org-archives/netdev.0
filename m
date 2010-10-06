From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] bonding: add retransmit membership reports tunable
Date: Tue, 05 Oct 2010 20:29:06 -0700 (PDT)
Message-ID: <20101005.202906.59690190.davem@davemloft.net>
References: <20101005220757.GB19931@redhat.com>
	<1286324639-22314-3-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, andy@greyhouse.net
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57384
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752891Ab0JFD2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 23:28:45 -0400
In-Reply-To: <1286324639-22314-3-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fleitner@redhat.com>
Date: Tue,  5 Oct 2010 21:23:59 -0300

> Allow sysadmins to configure the number of multicast
> membership report sent on a link failure event.
> 
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>

Also applied to net-next-2.6, thanks.
