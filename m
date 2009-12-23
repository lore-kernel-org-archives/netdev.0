From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/3] iwmc3200top: cleanup log messages
Date: Wed, 23 Dec 2009 14:16:43 -0800 (PST)
Message-ID: <20091223.141643.260084349.davem@davemloft.net>
References: <1260973586-10243-1-git-send-email-tomas.winkler@intel.com>
	<1260973586-10243-2-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mmc@vger.kernel.org,
	yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	guy.cohen@intel.com, ron.rindjunsky@intel.com
To: tomas.winkler@intel.com
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1260973586-10243-2-git-send-email-tomas.winkler@intel.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tomas Winkler <tomas.winkler@intel.com>
Date: Wed, 16 Dec 2009 16:26:25 +0200

> 1. add TRACE level
> 2. use TRACE where needed to reduce the noise
> 3  don't INFOEX from driver
> 4. add DUMP level for packets dumps
> 5. use correct context for the log messages
> 
> Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>

Applied.
