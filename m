From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1c: add error checking for pci_map_single functions
Date: Wed, 13 Feb 2013 13:33:22 -0500 (EST)
Message-ID: <20130213.133322.923786540726232949.davem@davemloft.net>
References: <1360629880-9920-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qca.qualcomm.com, nic-devel@qca.qualcomm.com,
	jwboyer@redhat.com
To: xiong@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360629880-9920-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: xiong <xiong@qca.qualcomm.com>
Date: Tue, 12 Feb 2013 08:44:40 +0800

> it is reported that code hit DMA-API errors on 3.8-rc6+,
> (see https://bugzilla.redhat.com/show_bug.cgi?id=908436, and
>      https://bugzilla.redhat.com/show_bug.cgi?id=908550)
> 
> this patch just adds error handler for
>     pci_map_single and skb_frag_dma_map.
> 
> Signed-off-by: xiong <xiong@qca.qualcomm.com>

Applied, thanks.
