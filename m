From: andrew hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCHv2 1/7] X25: Add if_x25.h and x25 to device identifiers
Date: Fri, 23 Apr 2010 11:02:28 +1000
Message-ID: <v2td45a3acc1004221802m573e83e5h8387da71fc90445a@mail.gmail.com>
References: <1271719717.2802.77.camel@ibex>
	 <20100420.163558.83598373.davem@davemloft.net>
	 <20100422.161342.60085636.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:47259 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754520Ab0DWBDq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 21:03:46 -0400
Received: by iwn8 with SMTP id 8so2422561iwn.16
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 18:03:45 -0700 (PDT)
In-Reply-To: <20100422.161342.60085636.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks!
Sorry for the delay, kernel is a spare time task at the moment.

On Fri, Apr 23, 2010 at 9:13 AM, David Miller <davem@davemloft.net> wro=
te:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 20 Apr 2010 16:35:58 -0700 (PDT)
>
>> From: Andrew Hendry <andrew.hendry@gmail.com>
>> Date: Tue, 20 Apr 2010 09:28:37 +1000
>>
>>> diff --git a/include/linux/if_x25.h b/include/linux/if_x25.h
>>> new file mode 100644
>>> index 0000000..897765f
>>> --- /dev/null
>>> +++ b/include/linux/if_x25.h
>>> @@ -0,0 +1,26 @@
>>> +/*
>>> + * =A0Linux X.25 packet to device interface
>>
>> Headers meant to be used by userspace must be added
>> to the include/linux/Kbuild file.
>
> I got tired of waiting days for you to get to this so I
> took care of it myself.
>
> All 7 patches applied to net-next-2.6
>
