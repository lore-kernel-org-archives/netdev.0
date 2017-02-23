From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next] net/gtp: Add udp source port generation
 according to flow hash
Date: Thu, 23 Feb 2017 15:58:15 +0200
Message-ID: <1092c633-bd88-c686-1cdb-3b5feb71d6c3@mellanox.com>
References: <1487257141-11706-1-git-send-email-ogerlitz@mellanox.com>
 <576077949.135577.1487282291666.JavaMail.zimbra@tpip.net>
 <CAJ3xEMijwHpWfxUFcaCiAkP_0P8R2u6Cv4L=Vc3b_dPf+beOBg@mail.gmail.com>
 <CALx6S34ibBFpmZvxAtUn6oqgX9M8C1a3gg1iZrWWzwbswatUSQ@mail.gmail.com>
 <20170223134947.GA4373@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        Andreas Schultz <aschultz@tpip.net>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        laforge <laforge@gnumonks.org>, netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0049.outbound.protection.outlook.com ([104.47.1.49]:43136
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750916AbdBWN6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 08:58:25 -0500
In-Reply-To: <20170223134947.GA4373@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/23/2017 3:49 PM, Pablo Neira Ayuso wrote:
> "The UDP Source Port is a locally allocated port number at the sending
> GTP-U entity."

and the proposed patch goes in that direction, agree?
