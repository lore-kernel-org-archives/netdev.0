From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH net-next #2 00/39] net_device.{base_addr, irq} removal update
Date: Fri, 6 Apr 2012 10:17:07 -0700
Message-ID: <CANEJEGuAz39DSsiEc7CWkMLY4FsqAC=seqtmyZ_moanyV+4xiA@mail.gmail.com>
References: <1333704408.git.romieu@fr.zoreil.com>
	<20120406.062626.578458566949440559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org, gallatin@myri.com,
	andy@greyhouse.net, chris.snook@gmail.com, venza@brownhat.org,
	DavidLv@viatech.com.cn, ionut@badula.org, jcliburn@gmail.com,
	jdmason@kudzu.us, mason@myri.com, mchan@broadcom.com,
	stas.yakovlev@gmail.com, steve.glendinning@smsc.com,
	thockin@hockin.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:50941 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152Ab2DFRRI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 13:17:08 -0400
Received: by obbtb18 with SMTP id tb18so3322138obb.19
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2012 10:17:07 -0700 (PDT)
In-Reply-To: <20120406.062626.578458566949440559.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 6, 2012 at 3:26 AM, David Miller <davem@davemloft.net> wrot=
e:
> From: Francois Romieu <romieu@fr.zoreil.com>
> Date: Fri, =C2=A06 Apr 2012 12:06:14 +0200
>
>> If there are no further changes, I'll rebase and send a single pull =
request
>> for the series including Grant's Acked-by once he says it is ok.
>
> Besides the request_irq() return value test issues, this series
> seems fine to me.

Ditto. I didn't see the request_irq() issue though. :( Oh well...this
is clearly an improvement.

thanks,
grant
