From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH net-next 0/3] Implement delete for BPF LPM trie
Date: Tue, 19 Sep 2017 23:13:27 +0200
Message-ID: <94373907-6cf5-22af-54e6-7625f31447e0@zonque.org>
References: <20170918193057.37644-1-kraigatgoog@gmail.com>
 <20170919.135530.717500199880384307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bugwerft.de ([46.23.86.59]:51546 "EHLO mail.bugwerft.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751341AbdISVN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 17:13:29 -0400
In-Reply-To: <20170919.135530.717500199880384307.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2017 10:55 PM, David Miller wrote:
> From: Craig Gallek <kraigatgoog@gmail.com>
> Date: Mon, 18 Sep 2017 15:30:54 -0400
> 
>> This was previously left as a TODO.  Add the implementation and
>> extend the test to cover it.
> 
> Series applied, thanks.
> 

Hmm, I think these patches need some more discussion regarding the IM
nodes handling, see the reply I sent an hour ago. Could you wait for
that before pushing your tree?


Thanks,
Daniel
