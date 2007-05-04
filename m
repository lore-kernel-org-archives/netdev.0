From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] [SCTP] Verify all destination ports in
 sctp_connectx.
Date: Fri, 04 May 2007 13:34:20 -0700 (PDT)
Message-ID: <20070504.133420.40833718.davem@davemloft.net>
References: <1178310175881-git-send-email-vladislav.yasevich@hp.com>
	<11783101751206-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55453
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031547AbXEDUeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 16:34:19 -0400
In-Reply-To: <11783101751206-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri,  4 May 2007 16:22:52 -0400

> We need to make sure that all destination ports are the same, since
> the association really must not connect to multiple different ports
> at once.  This was reported on the sctp-impl list.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
