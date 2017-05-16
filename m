From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 v2 repost 1/3] tc_filter: add support for chain
 index
Date: Tue, 16 May 2017 21:47:10 +0200
Message-ID: <20170516194710.GP1939@nanopsycho.orion>
References: <20170516172802.1317-1-jiri@resnulli.us>
 <20170516172937.1391-1-jiri@resnulli.us>
 <20170516111658.42b9191c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35158 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750930AbdEPTrN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 15:47:13 -0400
Received: by mail-wm0-f67.google.com with SMTP id v4so40485875wmb.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 12:47:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170516111658.42b9191c@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 16, 2017 at 08:16:58PM CEST, stephen@networkplumber.org wrote:
>On Tue, 16 May 2017 19:29:35 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Allow user to put filter to a specific chain identified by index.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>This will have to wait for the chain bits to show up upstream in net-next.
>

Sure. I just like to send the kernel patches alongside with the related
iproute2 patches. Thanks.
