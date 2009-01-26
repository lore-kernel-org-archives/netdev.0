From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netxen: fix vlan tso/checksum offload
Date: Mon, 26 Jan 2009 12:35:03 -0800 (PST)
Message-ID: <20090126.123503.110170997.davem@davemloft.net>
References: <1232856179-15153-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35590
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751914AbZAZUfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 15:35:01 -0500
In-Reply-To: <1232856179-15153-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sat, 24 Jan 2009 20:02:58 -0800

> o set netdev->vlan_features appropriately.
> o fix tso descriptor initialization for vlan case.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
