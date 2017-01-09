From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv2 net-next 0/5] sctp: add support for generating stream
 reconf chunks
Date: Tue, 10 Jan 2017 02:27:09 +0800
Message-ID: <CADvbK_dE74bAoTNo9gLczLuj71w3WMcPJ56tCFGJ=XjTMtTgRw@mail.gmail.com>
References: <cover.1483781759.git.lucien.xin@gmail.com> <20170109124325.GB20973@hmswarspite.think-freely.org>
 <20170109.105301.469495957021068521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neil Horman <nhorman@tuxdriver.com>,
        network dev <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35515 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163274AbdAIS1P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 13:27:15 -0500
In-Reply-To: <20170109.105301.469495957021068521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 9, 2017 at 11:53 PM, David Miller <davem@davemloft.net> wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 9 Jan 2017 07:43:25 -0500
>
>> These all look reasonably good, but it seems before we accept them,
>> there should be an additional patch that actually makes use of the code.
>> I presume that is forthcomming?
>
> This all comes from my asking that the original huge set of patches be
> split up.
>
> People always just rush this kind of work and never think about laying
> out the resubmission properly.
>
> One should always only submit new interfaces along with an actual use
> because only with a use can we properly review whether the new
> interface is good or not.

I was trying to keep the same order with rfc, but it seems not a good
idea, will resplit, thanks.
