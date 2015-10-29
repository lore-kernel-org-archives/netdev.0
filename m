From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/2] sh_eth: RX buffer alignment fixes
Date: Thu, 29 Oct 2015 22:58:11 +0300
Message-ID: <56327A53.5050307@cogentembedded.com>
References: <2249923.hKhT9K6gME@wasted.cogentembedded.com>
 <20151026.183250.557722955674085633.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:34630 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140AbbJ2T6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 15:58:15 -0400
Received: by lbbwb3 with SMTP id wb3so36596133lbb.1
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 12:58:14 -0700 (PDT)
In-Reply-To: <20151026.183250.557722955674085633.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/27/2015 04:32 AM, David Miller wrote:

>>     Here's a set of 2 patches against DaveM's 'net.git' repo which are the fixes
>> to the RX buffer size calculation.
>>
>> [1/2] sh_eth: fix RX buffer size alignment
>> [2/2] sh_eth: fix RX buffer size calculation
>
> Series applied, thanks.

    Will you queue these for stable?
    (I have some more fixes brewing...) :-)

MBR, Sergei
