From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvtap: Destroy minor_idr on module_exit
Date: Thu, 09 Jul 2015 00:04:41 -0700 (PDT)
Message-ID: <20150709.000441.95031278785903697.davem@davemloft.net>
References: <1436368609-30777-1-git-send-email-jthumshirn@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jthumshirn@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436368609-30777-1-git-send-email-jthumshirn@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Thumshirn <jthumshirn@suse.de>
Date: Wed,  8 Jul 2015 17:16:49 +0200

> Destroy minor_idr on module_exit, reclaiming the allocated memory.
> 
> This was detected by the following semantic patch (written by Luis Rodriguez
> <mcgrof@suse.com>)
 ...
> Signed-off-by: Johannes Thumshirn <jthumshirn@suse.de>

Applied, thanks.
