From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [patch iproute2/net-next] tc: add support for TRAP action
Date: Thu, 8 Jun 2017 19:26:12 +0200
Message-ID: <20170608192612.6a9c175a@griffin>
References: <20170605143832.7025-1-jiri@resnulli.us>
        <20170605143945.7094-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, edumazet@google.com,
        alexander.h.duyck@intel.com, stephen@networkplumber.org,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47542 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751706AbdFHR01 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 13:26:27 -0400
In-Reply-To: <20170605143945.7094-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  5 Jun 2017 16:39:45 +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/linux/pkt_cls.h | 5 +++++
>  tc/tc_util.c            | 3 +++
>  2 files changed, 8 insertions(+)

No documentation again. Please add the description of the new action to
a man page.

 Jiri
