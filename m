From: Marius Kotsbak <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Wed, 22 Jun 2011 17:24:55 +0200
Message-ID: <4E020947.8000601@gmail.com>
References: <201106141146.19097.oneukum@suse.de>	<1308519957-28860-1-git-send-email-marius@kotsbak.com> <20110619.155755.1854488306547854947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110619.155755.1854488306547854947.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 20. juni 2011 00:57, David Miller wrote:
> From: "Marius B. Kotsbak" <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Sun, 19 Jun 2011 23:45:56 +0200
>
>> Introducing driver for the network port of Samsung Kalmia based USB LTE modems.
>> It has also an ACM interface that previous patches associates with the "option"
>> module. To access those interfaces, the modem must first be switched from modem
>> mode using a tool like usb_modeswitch.
>>
>> As the proprietary protocol has been discovered by watching the MS Windows driver
>> behavior, there might be errors in the protocol handling, but stable and fast
>> connection has been established for hours with Norwegian operator NetCom that
>> distributes this modem with their LTE/4G subscription.
>>
>> More and updated information about how to use this driver is available here:
>>
>> http://www.draisberghof.de/usb_modeswitch/bb/viewtopic.php?t=465
>> https://github.com/mkotsbak/Samsung-GT-B3730-linux-driver
>>
>> Signed-off-by: Marius B. Kotsbak <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
> Please submit only one patch for adding a new driver.
>
> Adding a second patch that fixes the driver in various ways is
> just noise, put those fixes into this one initial patch instead.

Turned out the first patch already is accepted into Linus tree, so then
I send again just the second.

--
Marius


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
