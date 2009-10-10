From: Tomas Winkler <tomasw@gmail.com>
Subject: Re: [PATCH 1/3] iwmc3200top: Add Intel Wireless MultiCom 3200 top
	driver.
Date: Sat, 10 Oct 2009 11:38:50 +0200
Message-ID: <1ba2fa240910100238s709c31d3s6cb612f502b1086f@mail.gmail.com>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	cindy.h.kao@intel.com, guy.cohen@intel.com,
	ron.rindjunsky@intel.com, Tomas Winkler <tomas.winkler@intel.com>
To: davem@davemloft.net, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-mmc@vger.kernel.org
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 23, 2009 at 1:38 AM, Tomas Winkler <tomas.winkler@intel.com> wrote:
> This patch adds Intel Wireless MultiCom 3200 top driver.
> IWMC3200 is 4Wireless Com CHIP (GPS/BT/WiFi/WiMAX).
> Top driver is responsible for device initialization and firmware download.
> Firmware handled by top is responsible for top itself and
> as well as bluetooth and GPS coms. (Wifi and WiMax provide their own
> firmware)
> In addition top driver is used to retrieve firmware logs
> and supports other debugging features
>
> Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>

Dave,
are you going to merge this one?
iwmc3200wifi and i200m-sdio which are already merged are usless without it

Thanks
Tomas
