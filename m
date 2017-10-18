From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] net/sched: cls_flower: Set egress_dev mark when
 calling into the HW driver
Date: Wed, 18 Oct 2017 11:09:31 +0300
Message-ID: <86a62dfb-0ed5-804a-a9c4-a81374cde537@cogentembedded.com>
References: <1508145588-29959-1-git-send-email-ogerlitz@mellanox.com>
 <1a523077-3c05-ba97-8a65-1967765b8d5a@cogentembedded.com>
 <CAJ3xEMjWCL3kSvfenCaLYnbvmGfyS2-zig7MhVMa1+oUMCLpbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:53288 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757197AbdJRIJd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 04:09:33 -0400
Received: by mail-lf0-f44.google.com with SMTP id l23so4798079lfk.10
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 01:09:33 -0700 (PDT)
In-Reply-To: <CAJ3xEMjWCL3kSvfenCaLYnbvmGfyS2-zig7MhVMa1+oUMCLpbA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 10/18/2017 10:14 AM, Or Gerlitz wrote:

>>> Commit 7091d8c '(net/sched: cls_flower: Add offload support using egress
>>
>>     At least 12 digits are needed.
> 
> Also on such a spot (e.g not on the Fixes line)?

    Yes.

[...]

MBR, Sergei
