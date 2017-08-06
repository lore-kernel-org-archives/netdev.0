From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next 10/15] dsa: push cls_matchall setup_tc processing
 into a separate function
Date: Sun, 6 Aug 2017 10:55:50 -0700
Message-ID: <0de7518c-c889-0e04-b3c3-919d1aea5036@gmail.com>
References: <20170805145337.17728-1-jiri@resnulli.us>
 <20170805145337.17728-11-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:37821 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751343AbdHFRzy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 13:55:54 -0400
Received: by mail-oi0-f65.google.com with SMTP id j194so5809047oib.4
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2017 10:55:53 -0700 (PDT)
In-Reply-To: <20170805145337.17728-11-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/05/2017 07:53 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Let dsa_slave_setup_tc be a splitter for specific setup_tc types and
> push out cls_matchall specific code into a separate function.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
