From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v5 00/10] Support for the Broadcom GENET driver
Date: Thu, 13 Feb 2014 23:07:00 -0800
Message-ID: <52FDC094.1020104@gmail.com>
References: <1392336531-28875-1-git-send-email-f.fainelli@gmail.com> <20140214.002901.293996041341946875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	cernekee@gmail.com, mark.rutland@arm.com, romieu@fr.zoreil.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:50737 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbaBNHHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 02:07:03 -0500
In-Reply-To: <20140214.002901.293996041341946875.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/02/2014 21:29, David Miller a =E9crit :
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Thu, 13 Feb 2014 16:08:41 -0800
>
>> This patchset adds support for the Broadcom GENET Gigabit Ethernet M=
AC
>> controller. This controller is found on the Broadcom BCM7xxx Set Top=
 Box
>> System-on-a-chips.
>>
>> Changes since v4:
>> - add dependency on CONFIG_OF
>>
>> Changes since v3:
>> - fixed Kconfig dependency on FIXED_PHY
>>
>> Changes since v2:
>> - dropped the patch that adds an "internal" phy-mode
>
> Series applied, thanks.

Great, thanks David!
--
=46lorian
