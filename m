From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] New device ID for sc92031 [1088:2031]
Date: Mon, 20 Jul 2009 08:27:17 -0700 (PDT)
Message-ID: <20090720.082717.138297828.davem@davemloft.net>
References: <1248026612-12792-1-git-send-email-cesarb@cesarb.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, rain_maker@root-forum.org
To: cesarb@cesarb.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57006
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751379AbZGTP1M convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2009 11:27:12 -0400
In-Reply-To: <1248026612-12792-1-git-send-email-cesarb@cesarb.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Cesar Eduardo Barros <cesarb@cesarb.net>
Date: Sun, 19 Jul 2009 15:03:32 -0300

> rain_maker@root-forum.org wrote:
>> Hello cesar,
>>
>> In a recent thread in a german linux forum, a user reported his PIC
>> NIC not being recognized by the kernel.
>>
>> Fortunately he provided enough information and I was able to help hi=
m
>> and get the device working with the sc92031 driver.
>>
>> The device ID is [1088:2031] (Vendor is called "Microcomputer System=
s
>> (M) Son"), here is the respective thread in "ubuntuusers.de"
>>
>> http://forum.ubuntuusers.de/topic/lankarte-unter-xubuntu-wird-nicht-=
erkannt/
>>
>> (Although you might not speak german, the code provided will show
>> you, that the device is actually working with your driver).
>>
>> It would be nice, if you include this new device ID to the
>> sc92031-driver.
>>
>> Regards,
>>
>> Axel K=F6llhofer (aka Rain_Maker)
>=20
> Cc: rain_maker@root-forum.org
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>

Applied, thanks.
