From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/11] Removing dead ARCH_PNX010X
Date: Wed, 14 Jul 2010 13:39:16 -0700 (PDT)
Message-ID: <20100714.133916.71109591.davem@davemloft.net>
References: <cover.1279110894.git.siccegge@cs.fau.de>
	<395890e97bb1e879725ea56562f362d4af61c463.1279110895.git.siccegge@cs.fau.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, shemminger@vyatta.com,
	dongdong.deng@windriver.com, jkosina@suse.cz,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vamos-dev@i4.informatik.uni-erlangen.de
To: siccegge@cs.fau.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <395890e97bb1e879725ea56562f362d4af61c463.1279110895.git.siccegge@cs.fau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Egger <siccegge@cs.fau.de>
Date: Wed, 14 Jul 2010 14:41:09 +0200

> ARCH_PNX010X doesn't exist in Kconfig, therefore removing all
> references for it from the source code.
> 
> Signed-off-by: Christoph Egger <siccegge@cs.fau.de>

If you are going to kill this off, kill the references in
driver/net/Kconfig at the same time.

Please fix this up and resubmit your patch, thanks.
