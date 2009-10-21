From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next V2 1/3] iwmc3200top: Add Intel Wireless
 MultiCom  3200 top driver.
Date: Wed, 21 Oct 2009 21:52:47 +0900
Message-ID: <1256129568.7737.1.camel@localhost.localdomain>
References: <1255806576-26869-1-git-send-email-tomas.winkler@intel.com>
	 <20091019.215457.43252934.davem@davemloft.net>
	 <1ba2fa240910200453k4638dc6cm8c8911353ea85b60@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-mmc@vger.kernel.org, yi.zhu@intel.com,
	inaky.perez-gonzalez@intel.com, cindy.h.kao@intel.com,
	guy.cohen@intel.com, ron.rindjunsky@intel.com
To: Tomas Winkler <tomasw@gmail.com>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1ba2fa240910200453k4638dc6cm8c8911353ea85b60@mail.gmail.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tomas,

> >> This patch adds Intel Wireless MultiCom 3200 top driver.
> >> IWMC3200 is 4Wireless Com CHIP (GPS/BT/WiFi/WiMAX).
> >> Top driver is responsible for device initialization and firmware download.
> >> Firmware handled by top is responsible for top itself and
> >> as well as bluetooth and GPS coms. (Wifi and WiMax provide their own firmware)
> >> In addition top driver is used to retrieve firmware logs
> >> and supports other debugging features
> >>
> >> Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
> >
> > Applied to net-next-2.6
> 
> Thanks Dave
> 
> Marcel
> I want to send out now the BT driver, would like the patch against
> bluetooth-next-2.6.git, then I wait till you sync or can you also pick
> it from net-next if Dave is OK with that?

send it against net-next since you are working in drivers/bluetooth/, we
will have not conflicts.

Regards

Marcel


