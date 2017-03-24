From: Jonas Bonn <jonas@southpole.se>
Subject: Re: [PATCH net-next v3 0/2] GTP SGSN-side tunnels
Date: Fri, 24 Mar 2017 14:57:41 +0100
Message-ID: <1b705318-c537-7ae7-47bc-89a5fbb93abf@southpole.se>
References: <20170324093358.31374-1-jonas@southpole.se>
 <20170324104111.GA1466@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
        laforge@gnumonks.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:50653 "EHLO mail.southpole.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751533AbdCXN5t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 09:57:49 -0400
In-Reply-To: <20170324104111.GA1466@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2017 11:41 AM, Pablo Neira Ayuso wrote:
> On Fri, Mar 24, 2017 at 10:33:56AM +0100, Jonas Bonn wrote:
>> Changes since v2:
>>
>> * Move #define of legacy netlink attribute into enum
>> * Added note to commit message about load-testing use-case
>> * Ack from Pablo
> Thanks a lot Jonas!
>
> David, please apply. Thanks!

David, please apply v4 instead as it has a coding-style fixup requested 
by Harald.

Thanks,

Jonas
