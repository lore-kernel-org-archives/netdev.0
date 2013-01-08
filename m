From: Anirban Chakraborty <anirbanchak@gmail.com>
Subject: Re: [PATCH V1 01/14] qlcnic: change driver hardware interface mechanism
Date: Mon, 7 Jan 2013 23:18:47 -0800
Message-ID: <CAB=E=HBPrAm4FJnoF=3hhT2aOioD5=G9Qzq2aakNX+usEZk6mg@mail.gmail.com>
References: <1357046430-31437-1-git-send-email-sony.chacko@qlogic.com>
	<1357046430-31437-2-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:53114 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990Ab3AHHSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 02:18:47 -0500
Received: by mail-oa0-f44.google.com with SMTP id n5so70947oag.31
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 23:18:47 -0800 (PST)
In-Reply-To: <1357046430-31437-2-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 1, 2013 at 5:20 AM, Sony Chacko <sony.chacko@qlogic.com> wrote:
> From: Sony Chacko <sony.chacko@qlogic.com>
>
> Refactor 82xx driver to support new adapter - Qlogic 83XX CNA
>
> Create adapter abstraction layer and seperate 82xx hardware access routines.
> Create mailbox based HW interface mechanism
>
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
> ---
<snip>

Please do not use my sign-off since I do not work for QLogic anymore.
I do not know what is the right way of doing it. However, you may
acknowledge my name on the patch provided the patch is the same when I
last worked on it. Sign-off may not be appropriate as it contains
QLogic mail id which is not correct on the current date. I didn't get
a chance to look up netdev in last several months, and hence do not
know if any other patches have gone in with my sign-off since August,
2012. If so, please take care of those, provided there's a way to do
it.

Thanks,
Anirban
