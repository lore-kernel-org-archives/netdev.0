From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: Re: [RFC net-next v2] bridge lwtunnel, VPLS & NVGRE
Date: Tue, 19 Sep 2017 16:46:38 +0200
Message-ID: <6b7cdb61-9c24-3fcb-d23c-f08ca2144ec9@6wind.com>
References: <20170821171523.951260-1-equinox@diac24.net>
 <6a538120-1941-7e81-c942-e97adeff2e3d@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org
To: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
        bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:52638 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751307AbdISOqv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 10:46:51 -0400
Received: by mail-wr0-f181.google.com with SMTP id c23so200946wrg.9
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 07:46:50 -0700 (PDT)
In-Reply-To: <6a538120-1941-7e81-c942-e97adeff2e3d@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

What's next ? do you plan to send a v3 or should I do it ?

On 09/11/2017 10:02 AM, Amine Kherbouche wrote:
> Hi David,
>
> Do you plan to send a v3?
>
> On 21/08/2017 18:15, David Lamparter wrote:
>> Hi all,
>>
>>
>> this is an update on the earlier "[RFC net-next] VPLS support".  Note
>> I've changed the subject lines on some of the patches to better reflect
>> what they really do (tbh the earlier subject lines were crap.)
>>
>> As previously, iproute2 / FRR patches are at:
>> - https://github.com/eqvinox/vpls-iproute2
>> - https://github.com/opensourcerouting/frr/commits/vpls
>> while this patchset is also available at:
>> - https://github.com/eqvinox/vpls-linux-kernel
>> (but please be aware that I'm amending and rebasing commits)
