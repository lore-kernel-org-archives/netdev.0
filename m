From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 2/2] rtlwifi: Fix reusable codes in core.c
Date: Sat, 16 Apr 2016 12:39:04 +1000
Message-ID: <CAGRGNgX0uy=R1dd7UMO5aZu69QDUXrtZDCjdJnB1Yj3XzjemHA@mail.gmail.com>
References: <20160203020139.GA13619@gmail.com> <87bn5apw5a.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Byeoungwook Kim <quddnr145@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:34395 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbcDPCjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 22:39:25 -0400
In-Reply-To: <87bn5apw5a.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kalle,

On Sat, Apr 16, 2016 at 4:25 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
> Byeoungwook Kim <quddnr145@gmail.com> writes:
>
>> rtl_*_delay() functions were reused same codes about addr variable.
>> So i have converted to rtl_addr_delay() from code about addr variable.
>>
>> Signed-off-by: Byeoungwook Kim <quddnr145@gmail.com>
>> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>
>
> Doesn't apply:
>
> Applying: rtlwifi: Fix reusable codes in core.c
> fatal: sha1 information is lacking or useless (drivers/net/wireless/realtek/rtlwifi/core.c).
> Repository lacks necessary blobs to fall back on 3-way merge.
> Cannot fall back to three-way merge.
> Patch failed at 0001 rtlwifi: Fix reusable codes in core.c
>
> Please rebase and resend.

This one is already applied in some form. I thought I'd listed it in
my big list of superseded patches, however I must have missed it.

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
