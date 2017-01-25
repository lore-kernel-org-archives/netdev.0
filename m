From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [PATCH net-next v2] macb: Common code to enable ptp support for MACB/GEM
Date: Wed, 25 Jan 2017 15:07:55 +0530
Message-ID: <CAFcVECJML0bPvituu4LFRjhXgPkQcgeJ5hY64pg_XfR7uDwuxA@mail.gmail.com>
References: <1484841375-11420-1-git-send-email-andrei.pistirica@microchip.com>
 <9bc6b112-f79c-58e4-7d2b-718ee07ff3a1@atmel.com> <88d4aee3-cc38-b271-3f52-a28e5af7bdac@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Andrei Pistirica <andrei.pistirica@microchip.com>,
        netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        David Miller <davem@davemloft.net>,
        Harini Katakam <harini.katakam@xilinx.com>,
        Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        Anirudha Sarangi <anirudh@xilinx.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        alexandre.belloni@free-electrons.com, tbultel@pixelsurmer.com,
        Richard Cochran <richardcochran@gmail.com>,
        Rafal Ozieblo <rafalo@cadence.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34228 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751428AbdAYJh5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 04:37:57 -0500
In-Reply-To: <88d4aee3-cc38-b271-3f52-a28e5af7bdac@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 2:56 PM, Nicolas Ferre <nicolas.ferre@atmel.com> wr=
ote:
> Le 19/01/2017 =C3=A0 17:07, Nicolas Ferre a =C3=A9crit :
>> Le 19/01/2017 =C3=A0 08:56, Andrei Pistirica a =C3=A9crit :
>>> This patch does the following:
>>> - MACB/GEM-PTP interface
>>> - registers and bitfields for TSU
>>> - capability flags to enable PTP per platform basis
>>>
>>> Signed-off-by: Andrei Pistirica <andrei.pistirica@microchip.com>
>>
>> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Reviewed-by: Harini Katakam <harinik@xilinx.com>

>
> Harini or Rafal, do you plan to review this patch and add your
> "Reviewed-by" tags? It can be useful to make this support move forward.

Sure, reviewed and working with it, meant to add tag :)

Regards,
Harini
