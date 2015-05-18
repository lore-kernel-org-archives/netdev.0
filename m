From: Ilya Dmitrichenko <errordeveloper@gmail.com>
Subject: Re: Multicast packets visible on different subnets in different namespaces
Date: Mon, 18 May 2015 15:11:55 +0100
Message-ID: <CAPhDKbF0Ln5qMNCkRO56_Bmse1gYviHtyb6XEZ2Tju5zi_NcvA@mail.gmail.com>
References: <CAPhDKbGDCCs3xqLKVj2UE8Y-YFnyQ0dN_meLB0ULEeVy7tCECA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:34478 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbbEROL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 10:11:57 -0400
Received: by laat2 with SMTP id t2so221633426laa.1
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 07:11:55 -0700 (PDT)
In-Reply-To: <CAPhDKbGDCCs3xqLKVj2UE8Y-YFnyQ0dN_meLB0ULEeVy7tCECA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30 March 2015 at 13:05, Ilya Dmitrichenko <errordeveloper@gmail.com> wrote:
>
> The kernel versions we have tested are:
>
> 3.18.7-100 from Fedora 20.
> 3.19.0 from CoreOS

I have just retested this on 4.0.3 (using vanilla kernel from CoreOS)
and got same result.
