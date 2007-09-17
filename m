From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/8] SCTP: Tie ADD-IP and AUTH functionality as
 required by spec.
Date: Sun, 16 Sep 2007 19:34:54 -0700 (PDT)
Message-ID: <20070916.193454.40144336.davem@davemloft.net>
References: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
	<11897955003232-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60042
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751343AbXIQCe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 22:34:58 -0400
In-Reply-To: <11897955003232-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 14 Sep 2007 14:44:59 -0400

> ADD-IP spec requires AUTH. It is, in fact, dangerous without AUTH.
> So, disable ADD-IP functionality if the peer claims to support
> ADD-IP, but not AUTH.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6.24, thanks.
