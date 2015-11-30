From: Shrikrishna Khare <skhare@vmware.com>
Subject: Re: [PATCH] vmxnet3: fix checks for dma mapping errors
Date: Mon, 30 Nov 2015 11:53:15 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1511301151510.30452@shri-linux.eng.vmware.com>
References: <1448663370-6848-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448663370-6848-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 27 Nov 2015, Alexey Khoroshilov wrote:

> vmxnet3_drv does check dma_addr with dma_mapping_error()
> after mapping dma memory. The patch adds the checks and
> tries to handle failures.
> 

Typo: vmxnet3_drv does not check dma_addr...

> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> ---

Acked-by: Shrikrishna Khare <skhare@vmware.com>
