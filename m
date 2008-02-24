From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3][BNX2]: More 5706S link down workaround.
Date: Sat, 23 Feb 2008 19:48:12 -0800 (PST)
Message-ID: <20080223.194812.179399180.davem@davemloft.net>
References: <1203709778.13495.177.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57662
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751624AbYBXDrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 22:47:31 -0500
In-Reply-To: <1203709778.13495.177.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 22 Feb 2008 11:49:38 -0800

> [BNX2]: More 5706S link down workaround.
> 
> The previous patches to workaround the 5706S on an HP blade were not
> sufficient.  The link state still does not change properly in some
> cases.  This patch adds polling to make it completely reliable.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
