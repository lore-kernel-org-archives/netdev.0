From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v2] doc: document MSG_ZEROCOPY
Date: Fri, 1 Sep 2017 09:12:08 -0700
Message-ID: <bf9ab7e0-acb6-e29c-c7c6-97b02edd7c50@fb.com>
References: <20170901160141.54616-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <brouer@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51887 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751945AbdIAQMZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 12:12:25 -0400
In-Reply-To: <20170901160141.54616-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/1/17 9:01 AM, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Documentation for this feature was missing from the patchset.
> Copied a lot from the netdev 2.1 paper, addressing some small
> interface changes since then.
>
> Changes
>   v1 -> v2
>     - change email discussion URL format
>     - clarify that u32 counter is per-syscall, unsigned and
>       wraps after UINT_MAX calls
>     - describe errno on send failure specific to MSG_ZEROCOPY
>     - a few very minor rewordings
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
