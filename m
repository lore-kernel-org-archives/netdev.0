From: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Subject: Re: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
Date: Tue, 20 Jan 2015 11:34:24 +0800
Message-ID: <54BDCCC0.2080805@linux.intel.com>
References: <54B36C88.3030609@linux.intel.com> <54B39B59.8000907@broadcom.com> <877fwotddy.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: brudley@broadcom.com, Franky Lin <frankyl@broadcom.com>,
	meuleman@broadcom.com, linville@tuxdriver.com,
	pieterpg@broadcom.com, hdegoede@redhat.com, wens@csie.org,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>,
	Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877fwotddy.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2015/1/15 20:52, Kalle Valo wrote:
> Arend van Spriel <arend@broadcom.com> writes:
>
>> On 01/12/15 07:41, Fu, Zhonghui wrote:
>>>  From 8685c3c2746b4275fc808d9db23c364b2f54b52a Mon Sep 17 00:00:00 2001
>>> From: Zhonghui Fu<zhonghui.fu@linux.intel.com>
>>> Date: Mon, 12 Jan 2015 14:25:46 +0800
>>> Subject: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
>>>
>>> WiFi chip has 2 SDIO functions, and PM core will trigger
>>> twice suspend/resume operations for one WiFi chip to do
>>> the same things. This patch avoid this case.
>>>
>>> Acked-by: Arend van Spriel<arend@broadcom.com>
>>> Acked-by: Sergei Shtylyov<sergei.shtylyov@cogentembedded.com>
>>> Signed-off-by: Zhonghui Fu<zhonghui.fu@linux.intel.com>
>> This patch needs to be rebased.
>>
>> Kalle,
>>
>> Please drop this one.
> Ok, dropped. I'll wait for the rebase.
I have re-based this patch and sent it in another mail with the same subject.

Thanks,
Zhonghui
>
