From: David Miller <davem@davemloft.net>
Subject: Re: Regression: Bug 196547 - Since 4.12 - bonding module not
 working with wireless drivers
Date: Wed, 16 Aug 2017 14:01:52 -0700 (PDT)
Message-ID: <20170816.140152.199379342704102455.davem@davemloft.net>
References: <deb37db2-a55b-4010-475a-e756e67d3bc9@nurealm.net>
        <CADps9UCgqeUh41iHxCM+CTJh=Tffn-tiSYL2Q+NBb_8EppqRMA@mail.gmail.com>
        <2b6fd91a-f7cd-c2bf-6394-060d9b1f5d23@nurealm.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: futur.andy@googlemail.com, kvalo@codeaurora.org,
        arend.vanspriel@broadcom.com, maheshb@google.com,
        andy@greyhouse.net, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, greearb@candelatech.com,
        dcbw@redhat.com
To: james@nurealm.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38134 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752368AbdHPVBy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 17:01:54 -0400
In-Reply-To: <2b6fd91a-f7cd-c2bf-6394-060d9b1f5d23@nurealm.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Feeney <james@nurealm.net>
Date: Wed, 16 Aug 2017 14:44:27 -0600

> On 08/13/2017 11:42 AM, Andreas Born wrote:
>> On a side note I would recommend some of my own reading to you about
>> patch submission in general [1] and on netdev specifically [2].
> 
> Mmm - [2] and [3], I suspect.  Thanks Andreas.  I'll be studying those.  Yeah,
> I'm still learning what is needed and what works.  Sometimes, just a note to the
> author is more than enough to resolve a problem.  Sometimes, discussion is
> needed.  And other times... well, certain people are infamous... but no problem
> here, thankfully.
> 
>> And, just wondering, who's going to eventually close that bugreport?
>> https://bugzilla.kernel.org/show_bug.cgi?id=196547
> 
> I can close it when the patches actually land in the kernel.

All of the patches are in Linus's tree.
