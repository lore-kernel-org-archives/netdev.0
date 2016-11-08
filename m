From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: Why are IPv6 host and anycast routes referencing lo device?
Date: Mon, 7 Nov 2016 20:00:13 -0700
Message-ID: <ef509512-78f3-ed74-ee55-63d9c1fee39b@cumulusnetworks.com>
References: <db922fb9-2553-7801-d597-0f40999be944@cumulusnetworks.com>
 <14a4ccfb-11d9-f96b-a741-c8595b81ca45@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33020 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752149AbcKHDAQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 22:00:16 -0500
Received: by mail-pf0-f181.google.com with SMTP id d2so99842705pfd.0
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 19:00:16 -0800 (PST)
In-Reply-To: <14a4ccfb-11d9-f96b-a741-c8595b81ca45@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/7/16 7:26 PM, YOSHIFUJI Hideaki wrote:
> Once I tried I did not work.
> You could try again to see what happens.

I did and both worked fine in quick POC testing. I'll do more in-depth testing and send a patch. Thanks.
