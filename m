From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 01/10] net: phy: use network device in phy_print_status
Date: Wed, 12 Feb 2014 16:20:19 -0800
Message-ID: <CAGVrzcZQA6g73PmRoN7BJ8qDpUi5avHGrQ03L8cT4_PGqh_ACg@mail.gmail.com>
References: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
 <1392168462-18888-2-git-send-email-f.fainelli@gmail.com> <20140212.191313.1073971139703427607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:43327 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbaBMAU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 19:20:59 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so9652078pde.6
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 16:20:59 -0800 (PST)
In-Reply-To: <20140212.191313.1073971139703427607.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-12 16:13 GMT-08:00 David Miller <davem@davemloft.net>:
>
> Series applied, but this patch series had several problems which I want you
> absolutely to correct in future submissions.
>
> First of all, when you submit more than one patch at a time, you must
> provide a leading "PATCH 00/NN" posting which gives a top-level,
> detailed, description of the overall nature of the changes you are
> submitting.

Weird, did not you receive this cover-letter:
http://permalink.gmane.org/gmane.linux.network/303496
if not, that probably explains why the threading was all messed up in
your inbox.

>
> It also gives me a single, specific, posting to reply to when I reply
> the whole series.  Otherwise I have only two options, 1) pick an
> arbitrary patch to reply to (which I am doing right now) or 2) reply
> to every single patch (which is a serious waste of everyone's time).
>
> Furthermore, some of your patches added empty lines to the end of files.
> I corrected this by hand, but please avoid this in the future.

Thanks!

>
> Thank you.
>



-- 
Florian
