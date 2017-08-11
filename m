From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 2/2] wan: dscc4: convert to plain DMA API
Date: Fri, 11 Aug 2017 14:42:52 -0700 (PDT)
Message-ID: <20170811.144252.799953136088107644.davem@davemloft.net>
References: <1502405721-27738-1-git-send-email-khoroshilov@ispras.ru>
        <1502405721-27738-2-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502405721-27738-2-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Fri, 11 Aug 2017 01:55:21 +0300

> Make use the dma_*() interfaces rather than the pci_*() interfaces.
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied.
