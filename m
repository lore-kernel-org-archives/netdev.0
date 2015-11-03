From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: fix typo in RX descriptor bit name
Date: Tue, 3 Nov 2015 22:35:15 +0300
Message-ID: <56390C73.2030302@cogentembedded.com>
References: <2178116.o4gdOMzEUc@wasted.cogentembedded.com>
 <CAOJe8K1GbJ7N9YW31f8Ht8Qbb2av_vpeZPv7R60DuKV6vuDZKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:33310 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755723AbbKCTfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 14:35:19 -0500
Received: by lfbf136 with SMTP id f136so30293237lfb.0
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 11:35:18 -0800 (PST)
In-Reply-To: <CAOJe8K1GbJ7N9YW31f8Ht8Qbb2av_vpeZPv7R60DuKV6vuDZKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/03/2015 10:30 PM, Denis Kirjanov wrote:

>> Commit  7d7355f58ba4 ("sh_eth: Ensure proper ordering of descriptor active
>> bit write/read") did the right thing  but used too "heavy" barriers while
>> there were already "lighter" DMA barriers exactly  for this case...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
> Fix the subject line...

    Oops! Will fix in a jiffy...
    (I thought at first that you're commenting on the already applied patch. :-))

MBR, Sergei
