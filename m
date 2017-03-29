From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: debug ATU Age Time
Date: Tue, 28 Mar 2017 21:55:24 -0700 (PDT)
Message-ID: <20170328.215524.1898004534927511245.davem@davemloft.net>
References: <20170313192043.12478-1-vivien.didelot@savoirfairelinux.com>
        <87lgrpe0bi.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        jcobham@questertangent.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41656 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752496AbdC2E4E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 00:56:04 -0400
In-Reply-To: <87lgrpe0bi.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 28 Mar 2017 14:13:53 -0400

> Hi David,
> 
> Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:
> 
>> The ATU ageing time value programmed in the switch is rounded up to the
>> nearest multiple of its coefficient (variable depending on the model.)
>>
>> Add a debug message to inform the user about the exact programmed value.
>>
>> On 6352, "brctl setageing br0 18" gives "AgeTime set to 0x01 (15000 ms)"
>> while on 6390 we get "AgeTime set to 0x05 (18750 ms)".
>>
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> Can you pick this patch?

If it's not in a pending state in patchwork, there must be a reason.  And
that reason will tell you why I didn't apply it, and what needs to be
resolved in order to change that.

In any event, you have to at a minimum resubmit the patch.
