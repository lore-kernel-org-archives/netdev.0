From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 2/3] net: Introduce ife encapsulation module
Date: Fri, 3 Feb 2017 08:06:49 -0500
Message-ID: <2e396913-fa59-5114-9732-60e4cea0bbdf@mojatatu.com>
References: <1485955803-65065-1-git-send-email-yotamg@mellanox.com>
 <1485955803-65065-3-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Yotam Gigi <yotamg@mellanox.com>, davem@davemloft.net,
        netdev@vger.kernel.org, mrv@mojatatu.com, eladr@mellanox.com,
        jiri@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:34903 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751958AbdBCNGv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 08:06:51 -0500
Received: by mail-it0-f54.google.com with SMTP id 203so10823365ith.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 05:06:51 -0800 (PST)
In-Reply-To: <1485955803-65065-3-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-01 08:30 AM, Yotam Gigi wrote:
> This module is responsible for the ife encapsulation protocol
> encode/decode logics. That module can:
>  - ife_encode: encode skb and reserve space for the ife meta header
>  - ife_decode: decode skb and extract the meta header size
>  - ife_tlv_meta_encode - encodes one tlv entry into the reserved ife
>    header space.
>  - ife_tlv_meta_decode - decodes one tlv entry from the packet
>  - ife_tlv_meta_next - advance to the next tlv
>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>


Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
