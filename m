From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] drivers: net: usb: pegasus: bug fixing and cleanup
Date: Mon, 29 Apr 2013 14:04:24 -0400 (EDT)
Message-ID: <20130429.140424.2195591601359157776.davem@davemloft.net>
References: <alpine.DEB.2.02.1304261008410.3772@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: petkan@nucleusys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1304261008410.3772@fry.nucleusys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Petko Manolov <petkan@nucleusys.com>
Date: Fri, 26 Apr 2013 10:13:41 +0300 (EEST)

> From: Petko Manolov <petkan@nucleusys.com>
> 
> This series of patches is fixing a bug related to multiple control URB 
> submissions (noted by Sarah Sharp), optimizes read and write_mii_word 
> routines and removes socket buffer pool used in the receive path.
> 
> Signed-off-by: Petko Manolov <petkan@nucleusys.com>

Series applied, thanks.
