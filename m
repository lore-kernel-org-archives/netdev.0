From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH 4/5] rds: ib: add the static type to the function
Date: Thu, 9 Mar 2017 08:52:56 -0800
Message-ID: <c52121a4-56f2-5641-f2f3-e1c3d8fbdc8b@oracle.com>
References: <1489044405-26150-1-git-send-email-yanjun.zhu@oracle.com>
 <1489044405-26150-4-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhu Yanjun <yanjun.zhu@oracle.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:29997 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932452AbdCIQyc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 11:54:32 -0500
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
        by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v29GsUjW017780
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Thu, 9 Mar 2017 16:54:30 GMT
In-Reply-To: <1489044405-26150-4-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/8/2017 11:26 PM, Zhu Yanjun wrote:
> The function rds_ib_map_fmr is used only in the ib_fmr.c
> file. As such, the static type is added to limit it in this file.
>
> Cc: Joe Jin <joe.jin@oracle.com>
> Cc: Junxiao Bi <junxiao.bi@oracle.com>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
> ---
>  net/rds/ib_fmr.c | 5 +++--
>  net/rds/ib_mr.h  | 2 --
>  2 files changed, 3 insertions(+), 4 deletions(-)
>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
