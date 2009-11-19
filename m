From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/1] iwmc3200top: revamp fw name handling
Date: Wed, 18 Nov 2009 23:30:08 -0800 (PST)
Message-ID: <20091118.233008.18598625.davem@davemloft.net>
References: <1258588519-7939-1-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mmc@vger.kernel.org,
	yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	guy.cohen@intel.com, ron.rindjunsky@intel.com
To: tomas.winkler@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32772
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752595AbZKSH3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 02:29:50 -0500
In-Reply-To: <1258588519-7939-1-git-send-email-tomas.winkler@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomas Winkler <tomas.winkler@intel.com>
Date: Thu, 19 Nov 2009 01:55:19 +0200

> 1. define macro for handling firmware api version
> 2. add MODULE_FIRMWARE
> 3. cleanup iwmct_fw_load style
> 
> Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>

Applied, thanks.
