From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 1/2] net: dsa: lan9303: Move struct lan9303 to
 include/linux/lan9303.h
Date: Wed, 25 Oct 2017 13:07:54 +0200
Message-ID: <55972b2d-3d4e-b899-4baf-ad5252421de2@egil-hjelmeland.no>
References: <20171024093515.6749-1-privat@egil-hjelmeland.no>
 <20171024093515.6749-2-privat@egil-hjelmeland.no>
 <20171024163155.GB12347@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:42736 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751711AbdJYLIr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 07:08:47 -0400
In-Reply-To: <20171024163155.GB12347@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24. okt. 2017 18:31, Andrew Lunn wrote:
> On Tue, Oct 24, 2017 at 11:35:14AM +0200, Egil Hjelmeland wrote:
>> The next patch require net/dsa/tag_lan9303.c to access struct lan9303.
>> Therefore move struct lan9303 definitions from drivers/net/dsa/lan9303.h
>> to new file include/linux/lan9303.h.
>>
>> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
> 
> O.K, so not too bad.
> 
> I am now however wondering if include/linux/dsa/lan9303.h would be
> better?
> 

Me too. I can do that.


> Anyway,
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> 
>      Andrew
> 

Egil
