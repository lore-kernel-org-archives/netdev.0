From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/3] iwmc3200top: Add Intel Wireless MultiCom 3200 top
 driver.
Date: Sat, 10 Oct 2009 18:58:52 -0700 (PDT)
Message-ID: <20091010.185852.133969433.davem@davemloft.net>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
	<1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
	<1ba2fa240910100238s709c31d3s6cb612f502b1086f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	cindy.h.kao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, guy.cohen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1ba2fa240910100238s709c31d3s6cb612f502b1086f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Sat, 10 Oct 2009 11:38:50 +0200

> On Wed, Sep 23, 2009 at 1:38 AM, Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
>> This patch adds Intel Wireless MultiCom 3200 top driver.
>> IWMC3200 is 4Wireless Com CHIP (GPS/BT/WiFi/WiMAX).
>> Top driver is responsible for device initialization and firmware download.
>> Firmware handled by top is responsible for top itself and
>> as well as bluetooth and GPS coms. (Wifi and WiMax provide their own
>> firmware)
>> In addition top driver is used to retrieve firmware logs
>> and supports other debugging features
>>
>> Signed-off-by: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> Dave,
> are you going to merge this one?
> iwmc3200wifi and i200m-sdio which are already merged are usless without it

If it's not in netdev patchwork, I don't plan to add it.

If it is in patchwork, then it's in my backlog and I'll get to it.

People should never really have to ask me these questions, that's one
of the main points of:

	http://patchwork.ozlabs.org/project/netdev/list/

You can always see there what's "pending".
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
