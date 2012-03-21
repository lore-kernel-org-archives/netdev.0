From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: [PATCH v3 4/4] ath9k:  Support ethtool getstats api.
Date: Wed, 21 Mar 2012 08:12:02 -0700
Message-ID: <4F69EFC2.8030204@candelatech.com>
References: <1332183105-4447-1-git-send-email-greearb@candelatech.com> <1332183105-4447-4-git-send-email-greearb@candelatech.com> <4F684301.9040006@openwrt.org> <4F68B4AA.3070306@candelatech.com> <20329.32334.162938.169995@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sujith Manoharan <c_manoha-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20329.32334.162938.169995-4mDQ13Tdud8Jw5R7aSpS0dP8p4LwMBBS@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/21/2012 12:07 AM, Sujith Manoharan wrote:
> Ben Greear wrote:
>> I'd like to gather at least most stats always, so ethtool can work regardless
>> of debugfs.  But, that can be follow on patches in my opinion.  If it turns
>> out that we need another config option for this, then that is fine too.
>
> It would be good to have an option to compile this out. The information is
> available via the debugfs interface, so this is basically duplicating things.
> On APs using OpenWRT, debugfs is enabled by default, so we can just read
> the debugfs files.

Ok.  Hopefully at least the first 3 patches will go in, and when they do
I'll post some more patches for consideration.

Thanks,
Ben

-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
