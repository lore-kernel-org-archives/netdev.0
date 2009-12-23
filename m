From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/3] iwmc3200top: clean up fw_download
Date: Wed, 23 Dec 2009 14:16:37 -0800 (PST)
Message-ID: <20091223.141637.48501143.davem@davemloft.net>
References: <1260973586-10243-1-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mmc@vger.kernel.org,
	yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	guy.cohen@intel.com, ron.rindjunsky@intel.com
To: tomas.winkler@intel.com
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1260973586-10243-1-git-send-email-tomas.winkler@intel.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tomas Winkler <tomas.winkler@intel.com>
Date: Wed, 16 Dec 2009 16:26:24 +0200

> 1. removed redundant NULL-pointers checks in iwmct_fw_load
> as release_firmware and kfree are NULL pointer friendly
> 2. remove redundant memset of the parser since the structure
> is fully initialized in iwmct_fw_parser_init function
> 
> Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>

Applied.
