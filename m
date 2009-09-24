From: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Subject: Re: [PATCH 3/3 V2] i2400m-sdio: select IWMC3200TOP in Kconfig
Date: Thu, 24 Sep 2009 10:25:20 -0700
Message-ID: <1253813120.4219.0.camel@localhost.localdomain>
References: <1253779256-17058-1-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"Zhu, Yi" <yi.zhu@intel.com>,
	"Kao, Cindy H" <cindy.h.kao@intel.com>,
	"Cohen, Guy" <guy.cohen@intel.com>,
	"Rindjunsky, Ron" <ron.rindjunsky@intel.com>
To: "Winkler, Tomas" <tomas.winkler@intel.com>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1253779256-17058-1-git-send-email-tomas.winkler@intel.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-09-24 at 02:00 -0600, Winkler, Tomas wrote:
> i2400m-sdio requires iwmc3200top for its operation
> 
> create separate config option to separate 3200 specifics
> from eventual further wimax sdio HW.
> 
> Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>

Acked-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>

I'll merge this into the WiMAX tree.

-- 
-- Inaky


