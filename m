From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 26/26] drivers/net/: Use the DMA_{64,32}BIT_MASK constants
Date: Tue, 22 Mar 2005 19:01:15 -0500
Message-ID: <4240B1CB.3020103@pobox.com>
References: <20050306103404.12D9C1E46E@trashy.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, tklauser@nuerscht.ch
To: domen@coderock.org
In-Reply-To: <20050306103404.12D9C1E46E@trashy.coderock.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

domen@coderock.org wrote:
> Use the DMA_{64,32}BIT_MASK constants from dma-mapping.h
> when calling pci_set_dma_mask() or pci_set_consistent_dma_mask()
> 
> [Merged multiple patches, I can send split ones if desired -domen]

you don't need to split, but you do need to include linux/dma-mapping.h.

	Jeff
