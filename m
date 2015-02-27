From: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Subject: Re: [PATCH v3] brcmfmac: avoid duplicated suspend/resume operation
Date: Fri, 27 Feb 2015 15:53:21 +0800
Message-ID: <54F02271.5070202@linux.intel.com>
References: <54DC1D7D.5050407@linux.intel.com>	<54E0072D.3020802@linux.intel.com> <54E01209.7010300@erley.org>	<54E05961.7000201@broadcom.com> <878ufzi5s3.fsf@kamboji.qca.qualcomm.com> <54E19DA1.4030407@linux.intel.com> <54E1B9F4.6090302@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, Pat Erley <pat-lkml@erley.org>,
	brudley@broadcom.com, Franky Lin <frankyl@broadcom.com>,
	meuleman@broadcom.com, linville@tuxdriver.com,
	pieterpg@broadcom.com, hdegoede@redhat.com, wens@csie.org,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54E1B9F4.6090302@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2015/2/16 17:35, Arend van Spriel wrote:
> On 02/16/15 08:34, Fu, Zhonghui wrote:
>>
>> On 2015/2/15 22:54, Kalle Valo wrote:
>>> Arend van Spriel<arend@broadcom.com>  writes:
>>>
>>>> On 02/15/15 04:27, Pat Erley wrote:
>>>>> On 02/14/2015 08:40 PM, Fu, Zhonghui wrote:
>>>>>> Any comments to this patch? Can it be accepted?
>>>> I assume that patches are queued up until after the merge window that
>>>> we are currently in.
>>> That's right. In the future I will most likely apply patches also during
>>> the merge window, but as I'm still a greenhorn I'll be on the safe and
>>> wait for the merge window to end.
>> I am very glad to see this.
>> Could you please tell which release candidate this patch will be likely merged into now?
>
> For which tree are you asking this? When the merge window ends and linus' tree has moved to 3.20-rc1, the wireless-drivers-next will move to that -rc1 as well and pending/accepted patches will be applied for the next kernel release. If you are asking when they will be in linus' tree than the answer is 3.21-rc1. Now if you say this patch solves a real problem for you (providing usual proof like log with stack trace) you can request it to go on the wireless-drivers tree to be fixed for 3.20.

I was in Chinese new-year vacation these few days. So sorry for late response.

Many thanks for your explanation first. 

Now that there is not 3.20 version. My understanding is that this patch will be in linus' tree 4.1-rc1, right?


Thanks,
Zhonghui

>
> Regards,
> Arend
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
