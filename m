From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/1] net sched filters: fix filter handle ID in tfilter_notify_chain()
Date: Wed, 23 Nov 2016 08:34:18 +0100
Message-ID: <5835467A.7020207@iogearbox.net>
References: <1479866224-12285-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: Roman Mashak <mrv@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42162 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755876AbcKWHeX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 02:34:23 -0500
In-Reply-To: <1479866224-12285-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2016 02:57 AM, Roman Mashak wrote:
> Should pass valid filter handle, not the netlink flags.
>
> Fixes: 30a391a13ab92 ("net sched filters: pass netlink message flags in event notification")
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
