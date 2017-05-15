From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] ipv6: sr: fix user space compilation error with old
 glibc
Date: Mon, 15 May 2017 12:43:49 +0200
Message-ID: <59198665.7060908@iogearbox.net>
References: <20170515091828.19349-1-david.lebrun@uclouvain.be> <59197D53.8030104@iogearbox.net> <fa27cb59-a81e-7f74-7d3f-7feb6d8406f1@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58943 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdEOKnv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 06:43:51 -0400
In-Reply-To: <fa27cb59-a81e-7f74-7d3f-7feb6d8406f1@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2017 12:37 PM, David Lebrun wrote:
> On 05/15/2017 12:05 PM, Daniel Borkmann wrote:
>>
>> Or, is there still another fix for iproute2 coming after this has
>> landed?
>
> Yes, I will submit the fix to iproute2 once this one has been applied,
> so that I can reference it.

Okay, thanks!
