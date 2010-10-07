From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP: Fix setting of snd_ssthresh in
 tcp_mtu_probe_success
Date: Wed, 06 Oct 2010 21:18:20 -0700 (PDT)
Message-ID: <20101006.211820.200357156.davem@davemloft.net>
References: <1286422913-30034-1-git-send-email-johnwheffner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751235Ab0JGER7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 00:17:59 -0400
In-Reply-To: <1286422913-30034-1-git-send-email-johnwheffner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Heffner <johnwheffner@gmail.com>
Date: Wed,  6 Oct 2010 23:41:53 -0400

> This looks like a simple typo that has gone unnoticed for some time.  The
> impact is relatively low but it's clearly wrong.
> 
> Signed-off-by: John Heffner <johnwheffner@gmail.com>

Amazing how long something like this can survive :-)

Applied, thanks John.
