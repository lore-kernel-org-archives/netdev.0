From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] be2net: Fix a typo in be_cmds.h
Date: Tue, 06 Oct 2009 17:35:35 -0700 (PDT)
Message-ID: <20091006.173535.107137503.davem@davemloft.net>
References: <20091005122154.GA22954@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50782
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933796AbZJGAfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 20:35:40 -0400
In-Reply-To: <20091005122154.GA22954@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Mon, 5 Oct 2009 17:52:05 +0530

> MCC_STATUS_NOT_SUPPORTED should be decimal 66 not hex 66.
> This patch fixes this typo. Patch against net-2.6 tree.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
