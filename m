From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] net: thunderx: Add multiqset support for DPDK
Date: Thu, 21 Apr 2016 15:31:44 -0400 (EDT)
Message-ID: <20160421.153144.774884339123710587.davem@davemloft.net>
References: <1461221872-38841-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com,
	robert.richter@caviumnetworks.com
To: sunil.kovvuri@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461221872-38841-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: sunil.kovvuri@gmail.com
Date: Thu, 21 Apr 2016 12:27:48 +0530

> This patch series mainly adds support for userspace application
> like DPDK with a VNIC VF attached to request additional QSets
> for having morethan the default 8 queues.

I don't think it's appropriate to add facilities for non-upstream
features, especially DPDK.

Thanks.
