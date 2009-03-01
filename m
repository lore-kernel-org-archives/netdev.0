From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 0/3] Introduce the Intel 82599 10 Gigabit Network
	Adapter family
Date: Sun, 1 Mar 2009 02:30:42 -0800
Message-ID: <9929d2390903010230k7ed97b3du45e37c51ec742d37@mail.gmail.com>
References: <20090228013916.22664.54781.stgit@lost.foo-projects.org>
	 <20090301.002515.46575653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:59596 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbZCAKap convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 05:30:45 -0500
Received: by an-out-0708.google.com with SMTP id c2so1392888anc.1
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2009 02:30:43 -0800 (PST)
In-Reply-To: <20090301.002515.46575653.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 1, 2009 at 12:25 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri, 27 Feb 2009 17:44:16 -0800
>
>> The following series implements basic support for the new Intel 8259=
9 10 Gigabit Network adapter. =C2=A0Contained in this patchset is:
>>
>> =C2=A0 =C2=A0 =C2=A0 1) Hardware specific code to initialize the 825=
99 device
>> =C2=A0 =C2=A0 =C2=A0 2) Include Data Center Bridging support for 825=
99
>> =C2=A0 =C2=A0 =C2=A0 3) Add the current device ID's for 82599, inclu=
ding a fully pluggable 1G/10G SFP+ NIC, and a KX/KX4 mezzanine card
>
> All applied.
>
> I look forward to seeing you guys followup on the I2C usage
> stuff Ben pointed out :-)
> --

Thanks Dave.

I know that PJ is actively working with Ben to see how we can
implement the in kernel I2C interface into the driver.

--=20
Cheers,
Jeff
