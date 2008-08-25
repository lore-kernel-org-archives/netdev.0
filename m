From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: add verification checks to SCTP_AUTH_KEY option
Date: Mon, 25 Aug 2008 15:17:05 -0700 (PDT)
Message-ID: <20080825.151705.193699685.davem@davemloft.net>
References: <20080825164440.GA504@kernel.sg>
	<12196959323990-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	security@kernel.org, eteo@redhat.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50569
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753685AbYHYWRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 18:17:09 -0400
In-Reply-To: <12196959323990-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 25 Aug 2008 16:25:32 -0400

> The structure used for SCTP_AUTH_KEY option contains a
> length that needs to be verfied to prevent buffer overflow
> conditions.  Spoted by Eugene Teo <eteo@redhat.com>.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied and queued up for -stable, thanks!
