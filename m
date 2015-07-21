From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [5/6] wireless: cw1200: Remove redundant spi driver bus
 initialization
Date: Tue, 21 Jul 2015 13:44:07 +0000 (UTC)
Message-ID: <20150721134407.E2E6E141061@smtp.codeaurora.org>
References: <1435071185-24586-1-git-send-email-borneo.antonio@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Solomon Peachy <pizza@shaftnet.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Antonio Borneo <borneo.antonio@gmail.com>,
	linux-kernel@vger.kernel.org
To: Antonio Borneo <borneo.antonio@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435071185-24586-1-git-send-email-borneo.antonio@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> In ancient times it was necessary to manually initialize the bus
> field of an spi_driver to spi_bus_type. These days this is done in
> spi_register_driver(), so we can drop the manual assignment.
> 
> Signed-off-by: Antonio Borneo <borneo.antonio@gmail.com>
> To: Solomon Peachy <pizza@shaftnet.org>
> To: Kalle Valo <kvalo@codeaurora.org>
> To: linux-wireless@vger.kernel.org
> To: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
