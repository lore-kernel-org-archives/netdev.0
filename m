From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH] net/mlx5e: avoid stack overflow in mlx5e_open_channels
Date: Tue, 26 Apr 2016 21:50:53 +0300
Message-ID: <CALzJLG_BZ_UiWkUgz_tLznRv7Y_V7cK8cDz_FruPupEqoT7--g@mail.gmail.com>
References: <1461590139-1396745-1-git-send-email-arnd@arndb.de>
 <5940636.9Nic57IXcZ@wuerfel> <CALzJLG-d1mTs9SdubELzQtczsiVY0cgzBc3BC6wJoBgx4Wg_+Q@mail.gmail.com>
 <23978128.X7F5UHGaYZ@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Achiad Shochat <achiad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Amir Vadai <amir-IB5XiEnQfqI@public.gmane.org>,
	Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <23978128.X7F5UHGaYZ@wuerfel>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 26, 2016 at 6:49 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> On Tuesday 26 April 2016 17:41:45 Saeed Mahameed wrote:
>> On Tue, Apr 26, 2016 at 4:53 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
>> >
>> > Sure, do you want to just edit this when you forward the patch, or
>> > do you need me to do it?
>> >
>>
>> Well, I won't say no if you want to do it
>>
>
> All I want is to get rid of the patch in my queue. I guess it's
> worth the 10 minute of work ;-)
>
> v2 coming
>
>         Arnd

Thank you Arnd, Appreciated.
Saeed.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
