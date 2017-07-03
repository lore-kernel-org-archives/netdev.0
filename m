From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] mlx4_en: make mlx4_log_num_mgm_entry_size static
Date: Mon, 3 Jul 2017 12:58:03 +0300
Message-ID: <c41bcdc8-94fa-596f-639b-f147576c8583@cogentembedded.com>
References: <1499060119-7063-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhu Yanjun <yanjun.zhu@oracle.com>, tariqt@mellanox.com,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        yuval.shaia@oracle.com, leon@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:35456 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754013AbdGCJ6F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 05:58:05 -0400
Received: by mail-lf0-f44.google.com with SMTP id b207so99505435lfg.2
        for <netdev@vger.kernel.org>; Mon, 03 Jul 2017 02:58:05 -0700 (PDT)
In-Reply-To: <1499060119-7063-1-git-send-email-yanjun.zhu@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 7/3/2017 8:35 AM, Zhu Yanjun wrote:

> The variable mlx4_log_num_mgm_entry_size is only called in main.c.
    s/called/used/.

> CC: Joe Jin <joe.jin@oracle.com>
> CC: Junxiao Bi <junxiao.bi@oracle.com>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
[...]

MBR, Sergei
