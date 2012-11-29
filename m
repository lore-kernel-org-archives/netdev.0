From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 1/3] MAINTAINERS: Add Mellanox ethernet driver - mlx4_en
Date: Thu, 29 Nov 2012 20:55:15 +0200
Message-ID: <CAPcc5PhCAi7EnjCG_7-W0jNvQ2tGrX4vMCt-6m8dVS+Jmwf_JQ@mail.gmail.com>
References: <1354194894-16527-1-git-send-email-amirv@mellanox.com>
	<1354209333-27672-1-git-send-email-amirv@mellanox.com>
	<1354209333-27672-2-git-send-email-amirv@mellanox.com>
	<1354210184.9874.8.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Oren Duer <oren@mellanox.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:47330 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136Ab2K2SzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:55:16 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so5829456eaa.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:55:15 -0800 (PST)
In-Reply-To: <1354210184.9874.8.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 29, 2012 at 7:29 PM, Joe Perches <joe@perches.com> wrote:
> On Thu, 2012-11-29 at 19:15 +0200, Amir Vadai wrote:
>> Set mlx4_en maintainer to Amir Vadai instead of Yevgeny Petrilin.
>>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>
>> ---
>>  MAINTAINERS |    7 +++++++
>>  1 files changed, 7 insertions(+), 0 deletions(-)
>>
>> diff --git a/MAINTAINERS b/MAINTAINERS
>> index 5d72dd5..67fd3de 100644
>> --- a/MAINTAINERS
>> +++ b/MAINTAINERS
>> @@ -4822,6 +4822,13 @@ F:     Documentation/scsi/megaraid.txt
>>  F:   drivers/scsi/megaraid.*
>>  F:   drivers/scsi/megaraid/
>>
>> +MELLANOX ETHERNET DRIVER (mlx4_en)
>> +M:   Amir Vadai <amirv@mellanox.com>
>> +L:   netdev@vger.kernel.org
>> +S:   Supported
>> +W:   http://www.mellanox.com
>> +Q:   http://patchwork.ozlabs.org/project/netdev/list/
>
> What about a file pattern?  Maybe
> F:      drivers/net/ethernet/mellanox/mlx/
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Right - will fix it

Thanks,
Amir
