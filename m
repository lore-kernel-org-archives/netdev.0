From: Rayagond Kokatanur <rayagond.kokatanur@gmail.com>
Subject: Re: which git repo to use for new network driver
Date: Sat, 24 May 2014 20:15:55 +0530
Message-ID: <CAAnKVihoE6fFP1BTZtswea3LND6e0kkwvTmjhst9ZTZj66nJqQ@mail.gmail.com>
References: <CAJ3bTp5CsoWPmpQQ90o5M7DFQR_WZ3o5XkeVDN3aQMJKBr7kbA@mail.gmail.com>
	<5380AFA4.1090708@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rayagond Kokatanur <rayagond@vayavyalabs.com>,
	netdev <netdev@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:61746 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbaEXOp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 10:45:56 -0400
Received: by mail-oa0-f43.google.com with SMTP id l6so6839988oag.2
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 07:45:55 -0700 (PDT)
In-Reply-To: <5380AFA4.1090708@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks you Oliver.

I am working on new Ethernet driver, so I will use next-next repo from :

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git

wwr
Raaygond


On 24 May 2014 20:11, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
>
>
> On 24.05.2014 16:37, Rayagond Kokatanur wrote:
>> Hi All,
>>
>> Which git repo should be used for developing new network driver,
>> net-next.git or net.git.
>
> New drivers and features always go via net-next.
> The net-tree is just for fixes.
>
> If you have e.g. a new wireless/bluetooth/CAN driver there's a
> wireless/bluetooth/CAN mailing list to post to alternatively.
>
> Regards,
> Oliver
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
