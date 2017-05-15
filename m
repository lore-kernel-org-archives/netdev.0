From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: iproute2 build error due to sr-ipv6 lwtunnel
Date: Mon, 15 May 2017 10:46:48 +0200
Message-ID: <59196AF8.90700@iogearbox.net>
References: <590AF0C3.6070006@iogearbox.net> <3c0c0584-338d-47d0-76d4-e4408decc2c1@uclouvain.be> <590AFA8A.30602@iogearbox.net> <59185B16.5020107@iogearbox.net> <6c156160-706e-7f87-117e-5c2c9784ec6f@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41695 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759911AbdEOIqu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 04:46:50 -0400
In-Reply-To: <6c156160-706e-7f87-117e-5c2c9784ec6f@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2017 09:56 AM, David Lebrun wrote:
> On 05/14/2017 03:26 PM, Daniel Borkmann wrote:
>>
>> David, are you still looking into fixing this?
>
> Sorry, I left the issue on the side and then forgot about it.
>
> Could you try the following iproute2 patch ? Thanks

Yep, that compiles fine for me, thanks!
