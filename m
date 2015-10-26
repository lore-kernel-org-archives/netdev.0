From: punit vara <punitvara@gmail.com>
Subject: Re: [PATCH v4 14/15] net: wireless: ath: Remove unneeded variable ret
 returning 0
Date: Tue, 27 Oct 2015 01:30:21 +0530
Message-ID: <CABXAfNJewoq3LL9S+cSEs3S+nQXN714JyKT_ys2+armMprVEgA@mail.gmail.com>
References: <1445539670-4018-1-git-send-email-punitvara@gmail.com>
	<5629316E.60106@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: jirislaby@gmail.com, Nick Kossifidis <mickflemm@gmail.com>,
	mcgrof@do-not-panic.com, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34778 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbbJZUAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 16:00:22 -0400
In-Reply-To: <5629316E.60106@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2015 at 12:26 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 10/22/2015 09:47 PM, Punit Vara wrote:
>
>> Remove black line suggested by Sergei
>
>
>    Such kind of comments should be under the --- tear line.
>
>>
>> This patch is to the ath5k/eeprom.c that fixes up warning caught by
>> coccicheck:
>>
>> Unneeded variable: "ret". Return "0" on line 980
>>
>> Remove unneeded variable ret created to return zero.
>>
>> Signed-off-by: Punit Vara <punitvara@gmail.com>
>
> [...]
>
> MBR, Sergei
>
Thanks you Sergei for review.

Actually I didnt know You have replied to this mail because this was
gone in some other folder of my mail box .. I will send this patch
again as you suggested . Will my other patches which are already
correct be added to wireless tree ? or I have to resend everything ?
