From: David Miller <davem@davemloft.net>
Subject: Re: Regression: Bug 196547 - Since 4.12 - bonding module not
 working with wireless drivers
Date: Wed, 16 Aug 2017 19:42:03 -0700 (PDT)
Message-ID: <20170816.194203.2292396744409301402.davem@davemloft.net>
References: <1502918561.30484.1.camel@redhat.com>
        <20170816.143116.1172751167543812070.davem@davemloft.net>
        <1502935907.30484.4.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: james@nurealm.net, futur.andy@googlemail.com, kvalo@codeaurora.org,
        arend.vanspriel@broadcom.com, maheshb@google.com,
        andy@greyhouse.net, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, greearb@candelatech.com
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44284 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751517AbdHQCmG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 22:42:06 -0400
In-Reply-To: <1502935907.30484.4.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Wed, 16 Aug 2017 21:11:47 -0500

> You'll probably say "aim for the 75% case" or something like that,
> which is fine, but then you're depending on your 75% case to be (a)
> single AP, (b) never move (eg, only bond wifi + ethernet), (c) little
> radio interference.  I'm not sure I'd buy that.  If I've put words in
> your mouth, forgive me.

You can interpret what I'm saying as "some reasonable value is
better than no value at all."

You can keep arguing about AP changes, radio interference, etc.
but anything is better than the current situation.

Start small and simple, try to handle everything over time and
gradually.
