From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 v2 repost 1/3] tc_filter: add support for chain
 index
Date: Tue, 16 May 2017 11:16:58 -0700
Message-ID: <20170516111658.42b9191c@xeon-e3>
References: <20170516172802.1317-1-jiri@resnulli.us>
        <20170516172937.1391-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33036 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdEPSRG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 14:17:06 -0400
Received: by mail-pf0-f179.google.com with SMTP id e193so84336427pfh.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 11:17:06 -0700 (PDT)
In-Reply-To: <20170516172937.1391-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 May 2017 19:29:35 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Allow user to put filter to a specific chain identified by index.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

This will have to wait for the chain bits to show up upstream in net-next.
