From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/5] be2net: Issue fw_init/clean cmds to fw
Date: Mon, 23 Nov 2009 10:45:52 -0800 (PST)
Message-ID: <20091123.104552.245605999.davem@davemloft.net>
References: <20091123080203.GA7778@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38692
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753896AbZKWSpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 13:45:34 -0500
In-Reply-To: <20091123080203.GA7778@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Mon, 23 Nov 2009 13:32:03 +0530

> These cmds are issued to the fw in probe/resume and remove/suspend
> paths to help fw execute some initialization and cleanup code.
> 
> This change needed the be_hw_up() code to be refactored as be_get_config().
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
