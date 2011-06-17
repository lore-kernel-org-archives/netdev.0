From: =?ISO-8859-1?Q?Marius_Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Fri, 17 Jun 2011 12:31:49 +0200
Message-ID: <4DFB2D15.5060006@gmail.com>
References: <20110611.162942.1706711069327005315.davem@davemloft.net>	<1307882102-31659-1-git-send-email-marius@kotsbak.com> <20110616.220112.882657314456163072.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110616.220112.882657314456163072.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Den 17. juni 2011 04:01, skrev David Miller:
> From: "Marius B. Kotsbak"<marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Sun, 12 Jun 2011 14:35:02 +0200
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
>> Signed-off-by: Marius B. Kotsbak<marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
> Applied, thanks.

Thanks, will send additional patches with improvements for non-x86 
proposed by Oliver soon.

--
Marius


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
