From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH 0/9] net: thunderx: Adds XDP support
Date: Wed, 3 May 2017 23:39:04 +0300
Message-ID: <CAKoUArku6tRuV=Y3fteY-R6eHM4daq-0ct6w1_unjkGA+yPTFQ@mail.gmail.com>
References: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
 <20170502.154744.1762061314370744901.davem@davemloft.net> <CA+sq2CfW89EbiZmp6byc3y3cbATmmyVB=avzrUXG51-x3yxckg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sunil Goutham <sgoutham@cavium.com>,
        linux-arm-kernel@lists.infradead.org,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:37791 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932620AbdECUjG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 16:39:06 -0400
In-Reply-To: <CA+sq2CfW89EbiZmp6byc3y3cbATmmyVB=avzrUXG51-x3yxckg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, Sunil.

>with network stack: 0.32 Mpps
>with XDP (XDP_TX): 3 Mpps
>and XDP_DROP: 3.8 Mpps

Interesting; May I ask - which packet size did you use ?

Regards,
Rami Rosen
