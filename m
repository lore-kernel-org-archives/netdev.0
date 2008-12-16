From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/2] move flow control definitions to mii.h
Date: Tue, 16 Dec 2008 02:00:28 -0800 (PST)
Message-ID: <20081216.020028.20961543.davem@davemloft.net>
References: <1229258301-5073-1-git-send-email-steve.glendinning@smsc.com>
	<1229258301-5073-2-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34813
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752135AbYLPKA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 05:00:27 -0500
In-Reply-To: <1229258301-5073-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Sun, 14 Dec 2008 12:38:20 +0000

> flags used within drivers for indicating tx and rx flow control are
> defined in 4 drivers (and probably more), move these constants to mii.h.
> 
> The 3 SMSC drivers use the same constants (FLOW_CTRL_TX), but TG3 uses
> TG3_FLOW_CTRL_TX, so this patch also renames the constants within TG3.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.
