From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: high latency with TCP connections
Date: Fri, 1 Sep 2006 12:44:48 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0609011241470.20878@netcore.fi>
References: <20060831151456.12a4e080@dxpl.pdx.osdl.net>
 <20060831.154428.35684218.davem@davemloft.net> <20060831232923.GA10036@ms2.inr.ac.ru>
 <20060831.165701.104033558.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:32698 "EHLO netcore.fi")
	by vger.kernel.org with ESMTP id S1751357AbWIAJoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 05:44:55 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060831.165701.104033558.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 31 Aug 2006, David Miller wrote:
...
>> Probably, aspect 1 of ABC just should be disabled. And the first my
>> suggestion looks working too.
>
> I'm ready to rip out ABC entirely, to be honest.  Or at least
> turn it off by default.

Just as a curious observer:  do you think these issues are due to ABC 
implementation, or due to ABC specification?

I.e., should the ABC specification be 1) revised to fix specification 
bugs/omissions, 2) revised to document assumptions better, 3) 
deprecated due to FOO, 4) recommended for use, or 5) something else?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
