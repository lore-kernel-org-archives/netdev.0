From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH 0/3] drivers: net: usb: pegasus: bug fixing and cleanup
Date: Fri, 26 Apr 2013 11:44:05 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1304261142070.12284@fry.nucleusys.com>
References: <alpine.DEB.2.02.1304261008410.3772@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1304261008410.3772@fry.nucleusys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 26 Apr 2013, Petko Manolov wrote:

> From: Petko Manolov <petkan@nucleusys.com>
> 
> This series of patches is fixing a bug related to multiple control URB 
> submissions (noted by Sarah Sharp), optimizes read and write_mii_word 
> routines and removes socket buffer pool used in the receive path.
> 
> Signed-off-by: Petko Manolov <petkan@nucleusys.com>

I realized that the diffs for this patch series have been made in my git 
repository, not against your latest net-next tree.  Please ignore the 
first set of patches.
