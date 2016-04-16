From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 2/2] rtlwifi: Fix reusable codes in core.c
Date: Sat, 16 Apr 2016 07:31:32 +0300
Message-ID: <8737qmp42j.fsf@kamboji.qca.qualcomm.com>
References: <20160203020139.GA13619@gmail.com>
	<87bn5apw5a.fsf@kamboji.qca.qualcomm.com>
	<CAGRGNgX0uy=R1dd7UMO5aZu69QDUXrtZDCjdJnB1Yj3XzjemHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Byeoungwook Kim <quddnr145@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51307 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbcDPEbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 00:31:40 -0400
In-Reply-To: <CAGRGNgX0uy=R1dd7UMO5aZu69QDUXrtZDCjdJnB1Yj3XzjemHA@mail.gmail.com>
	(Julian Calaby's message of "Sat, 16 Apr 2016 12:39:04 +1000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Calaby <julian.calaby@gmail.com> writes:

> Hi Kalle,
>
> On Sat, Apr 16, 2016 at 4:25 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
>> Byeoungwook Kim <quddnr145@gmail.com> writes:
>>
>>> rtl_*_delay() functions were reused same codes about addr variable.
>>> So i have converted to rtl_addr_delay() from code about addr variable.
>>>
>>> Signed-off-by: Byeoungwook Kim <quddnr145@gmail.com>
>>> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>
>>
>> Doesn't apply:
>>
>> Applying: rtlwifi: Fix reusable codes in core.c
>> fatal: sha1 information is lacking or useless (drivers/net/wireless/realtek/rtlwifi/core.c).
>> Repository lacks necessary blobs to fall back on 3-way merge.
>> Cannot fall back to three-way merge.
>> Patch failed at 0001 rtlwifi: Fix reusable codes in core.c
>>
>> Please rebase and resend.
>
> This one is already applied in some form. I thought I'd listed it in
> my big list of superseded patches, however I must have missed it.

Or I missed it :) But good to know, so no actions needed anymore.

-- 
Kalle Valo
