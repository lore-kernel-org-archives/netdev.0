From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] uapi: consolidate DIV_ROUND_UP
 definition
Date: Fri, 04 Mar 2016 16:10:59 -0500 (EST)
Message-ID: <20160304.161059.1504063385320881771.davem@davemloft.net>
References: <20160303.170804.2300821465150459193.davem@davemloft.net>
	<1457088739-1065-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk, kxie@chelsio.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org,
	airlied@linux.ie, dri-devel@lists.freedesktop.org
To: nicolas.dichtel@6wind.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457088739-1065-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri,  4 Mar 2016 11:52:15 +0100

> The inital goal was to consolidate ethtool.h uapi header. But I took the
> opportunity to remove all duplicate definitions of DIV_ROUND_UP.
> 
> v3: add patch #2 and #3
> 
> v2: split the patch
>     define DIV_ROUND_UP in uapi

Series applied, thanks for so thoroughly taking care of this.
