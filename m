From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next 0/5] mlx4 misc fixes and improvements
Date: Sun, 18 Sep 2016 10:27:23 +0300
Message-ID: <80a8e8c5-689e-a2b1-e2d4-817dc0649385@gmail.com>
References: <1473686416-11779-1-git-send-email-tariqt@mellanox.com>
 <20160915.192106.739428651744920778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com
To: David Miller <davem@davemloft.net>, tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32819 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756263AbcIRH11 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 03:27:27 -0400
Received: by mail-wm0-f65.google.com with SMTP id w84so2814841wmg.0
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 00:27:26 -0700 (PDT)
In-Reply-To: <20160915.192106.739428651744920778.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On 16/09/2016 2:21 AM, David Miller wrote:
> From: Tariq Toukan <tariqt@mellanox.com>
> Date: Mon, 12 Sep 2016 16:20:11 +0300
>
>> This patchset contains some bug fixes, a cleanup, and small improvements
>> from the team to the mlx4 Eth and core drivers.
>>
>> Series generated against net-next commit:
>> 02154927c115 "net: dsa: bcm_sf2: Get VLAN_PORT_MASK from b53_device"
>>
>> Please push the following patch to -stable  >= 4.6 as well:
>> "net/mlx4_core: Fix to clean devlink resources"
> Again, coding style fixes and optimizations like branch prediction
> hints are not bug fixes and therefore not appropriate for 'net'.
Yes, I know. Please notice that it was submitted to net-next this time.

Regards,
Tariq
