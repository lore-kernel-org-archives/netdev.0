From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [patch net-next 10/20] net: sched: cls_bpf: rename cls_bpf_modify_existing
 function
Date: Mon, 31 Jul 2017 11:30:45 +0200
Message-ID: <597EF8C5.3050504@iogearbox.net>
References: <20170728144042.6380-1-jiri@resnulli.us> <20170728144042.6380-11-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40523 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750748AbdGaJaw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 05:30:52 -0400
In-Reply-To: <20170728144042.6380-11-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/28/2017 04:40 PM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> The name cls_bpf_modify_existing is highly misleading, as it indeed does
> not modify anything existing. It does not modify at all.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
