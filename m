From: Vinod Koul <vinod.koul@intel.com>
Subject: Re: [PATCH] asm-generic: remove old nonatomic-io wrapper files
Date: Mon, 29 Feb 2016 11:35:56 +0530
Message-ID: <20160229060556.GF11154@localhost>
References: <1456496980-1852604-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>,
	linux-arm-kernel@lists.infradead.org,
	Dan Williams <dan.j.williams@intel.com>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	Rolf Neugebauer <rolf.neugebauer@netronome.com>,
	"David S. Miller" <davem@davemloft.net>,
	Yisen Zhuang <yisen.zhuang@huawei.com>,
	yankejian <yankejian@huawei.com>,
	kenneth Lee <liguozhu@hisilicon.com>,
	huangdaode <huangdaode@hisilicon.com>,
	lipeng <lipeng321@huawei.com>, linux-kernel@vger.kernel.org,
	dmaengine@vger.kernel.org, netdev@vger.kernel.org,
	oss-drivers@netronome.com, linux-arch@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456496980-1852604-1-git-send-email-arnd@arndb.de>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 26, 2016 at 03:29:05PM +0100, Arnd Bergmann wrote:
> The two header files got moved to include/linux, and most
> users were already converted, this changes the remaining drivers
> and removes the files.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/dma/idma64.h                                | 2 +-
For this:

Acked-by: Vinod Koul <vinod.koul@intel.com>

Thanks
-- 
~Vinod
