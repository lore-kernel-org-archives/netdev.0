From: Sharat Masetty <sharat04@gmail.com>
Subject: Re: Multiqueue TX
Date: Mon, 28 Jul 2014 16:37:25 -0600
Message-ID: <CAJzFV36cL9=qNcF-cb0OSx1A39FP2Gaa98HBqr9D35fQ3BfU=Q@mail.gmail.com>
References: <CAJzFV37uOC15X+3PR0UJDsBGvMzRP9JRDp16CH8-OiiTv2NM7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:39432 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890AbaG1Wh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 18:37:27 -0400
Received: by mail-wi0-f177.google.com with SMTP id ho1so51571wib.10
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 15:37:25 -0700 (PDT)
In-Reply-To: <CAJzFV37uOC15X+3PR0UJDsBGvMzRP9JRDp16CH8-OiiTv2NM7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Can you please answer my question when you get a chance?

Regards,
Sharat

On Sat, Jul 26, 2014 at 1:31 AM, Sharat Masetty <sharat04@gmail.com> wrote:
> I have a question from this David's nice presentation
> http://vger.kernel.org/~davem/davem_nyc09.pdf on multiqueue TX. My
> questions are on the slide named "PICTURE WITH NON-TRIVIAL QDISC"
>
> 1)  What is the rationale behind such an arrangement, where one would
> have multiple TX queues pointing to the on single Qdisc?
> 2)  If the Qdisc in this illustration was a non trivial Qdisc such as
> htb, which has multiple leaf Qdisc's, how would the traffic shaping be
> preserved?
> 3) How would the back pressure/flow control of these individual TX
> queues work in this case?
>
> Thanks
> Sharat
