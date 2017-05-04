From: Pavel Belous <pavel.belous@aquantia.com>
Subject: Re: [PATCH] net:ethernet:aquantia:atlantic: Switch to use
 napi_gro_receive
Date: Thu, 4 May 2017 17:53:06 +0300
Message-ID: <c938a4be-76e0-eef8-381f-79b188870ddf@aquantia.com>
References: <16bc94e6bb9cc977a9a9e0cac48ae91ff7198f05.1493829200.git.pavel.belous@aquantia.com>
 <20170504.104257.1536182180703411206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darcari@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0055.outbound.protection.outlook.com ([104.47.40.55]:5216
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751500AbdEDOyI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 10:54:08 -0400
In-Reply-To: <20170504.104257.1536182180703411206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04.05.2017 17:42, David Miller wrote:
> From: Pavel Belous <Pavel.Belous@aquantia.com>
> Date: Wed,  3 May 2017 19:57:10 +0300
>
>> From: Pavel Belous <pavel.belous@aquantia.com>
>>
>> Add support for GRO (generic receive offload) for aQuantia Atlantic driver.
>> This results in a perfomance improvement when GRO is enabled.
>>
>> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
>
> Please format your Subject line properly.
>
> You have _way_ too many subsystem prefixes, and when there are more
> than one they should be separated by spaces like "a: b: c:"
>
> In this case an appropriate Subject line would be:
>
> [PATCH net-next] aquantia: Switch to use napi_gro_receive().
>
> But since this is a new feature, and the net-next tree is currently
> closed, you will have to resubmit this when the net-next tree
> opens.
>
> Thank you.
>

Ok. I will re-submit the patch when net-next tree opens.

Thank you,
Pavel
