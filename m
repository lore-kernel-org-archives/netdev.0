From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: prism54: fix checks for dma mapping errors
Date: Thu, 31 Dec 2015 08:24:07 +0000 (UTC)
Message-ID: <20151231082407.F20E76034E@smtp.codeaurora.org>
References: <1451083361-13141-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"John W . Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451083361-13141-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> prism54 checks for dma mapping errors by comparison returned address
> with zero, while pci_dma_mapping_error() should be used.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
