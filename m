From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/2] Don't return NULL from get_phy_device() anymore
Date: Mon, 16 May 2016 21:03:41 +0300
Message-ID: <d0d1cfea-2e0f-cf6c-5a87-a3f230e96b17@cogentembedded.com>
References: <7078673.lTHka36u4G@wasted.cogentembedded.com>
 <20160516.135349.1027929193904713083.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:36426 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754199AbcEPSDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 14:03:45 -0400
Received: by mail-lf0-f50.google.com with SMTP id u64so120372565lff.3
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 11:03:44 -0700 (PDT)
In-Reply-To: <20160516.135349.1027929193904713083.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/16/2016 08:53 PM, David Miller wrote:

>>    Here's the set of 2 patches against DaveM's 'net-next.git' repo. We save
>> several LoCs on the unneeded local variables....
>>
>> [1/2] lxt: simplify lxt97[01]_config_intr()
>> [2/2] lxt: simplify lxt970_config_init()
>
> I'm pretty sure that Subject isn't accurate so I didn't include it in the
> merge commit for this series :)

    I have instantly reposted the cover letter. :-)

> Series applied, thanks.

    Thank you.
    I thought I also found a bug in this driver but it was a false alarm -- 
the libphy code is sometimes hard to get right. :-)

MBR, Sergei
