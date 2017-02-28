From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH 1/1] rds: ib: add the static type to the variables
Date: Tue, 28 Feb 2017 08:42:00 -0800
Message-ID: <d8912e8e-7c18-4815-93e2-f0edbdad5aa0@oracle.com>
References: <1488264340-20044-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhu Yanjun <yanjun.zhu@oracle.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:43133 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdB1QpS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 11:45:18 -0500
In-Reply-To: <1488264340-20044-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/27/2017 10:45 PM, Zhu Yanjun wrote:
> The variables rds_ib_mr_1m_pool_size and rds_ib_mr_8k_pool_size
> are used only in the ib.c file. As such, the static type is
> added to limit them in this file.
>
> Cc: Joe Jin <joe.jin@oracle.com>
> Cc: Junxiao Bi <junxiao.bi@oracle.com>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
> ---
Looks good.
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
