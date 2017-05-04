From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: struct ip vs struct iphdr
Date: Thu, 4 May 2017 10:08:46 -0700
Message-ID: <d56b2182-3c81-5c52-5d77-8be128088e1b@oracle.com>
References: <20170504164219.GA25287@legohost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Oleg <lego12239@yandex.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49195 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751745AbdEDRIw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 13:08:52 -0400
In-Reply-To: <20170504164219.GA25287@legohost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/17 9:42 AM, Oleg wrote:
>   Hi, all.
>
> It seems struct ip and struct iphdr are similar: struct ip, despite of
> it name, doesn't contain anything but ip header.
>
> So, my noob question, what is the difference between them?

Also, see this:

http://stackoverflow.com/questions/42840636/difference-between-struct-ip-and-struct-iphdr

>
> Thanks.
>
