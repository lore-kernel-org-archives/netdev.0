From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] SCTP: Implement SCTP-AUTH initializations.
Date: Sun, 16 Sep 2007 19:31:48 -0700 (PDT)
Message-ID: <20070916.193148.01049897.davem@davemloft.net>
References: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
	<11897954992191-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39469
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751101AbXIQCbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 22:31:48 -0400
In-Reply-To: <11897954992191-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 14 Sep 2007 14:44:54 -0400

> The patch initializes AUTH related members of the generic SCTP
> structures and provides a way to enable/disable auth extension.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6.24
