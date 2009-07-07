From: Pablo Bitton <pablo.bitton@gmail.com>
Subject: Re: [v2] davinci_emac: fix kernel oops when changing MAC address
	while interface is down
Date: Tue, 7 Jul 2009 08:51:48 +0300
Message-ID: <7448ec710907062251w176989dm38b7bb56dd944742@mail.gmail.com>
References: <20090706.182037.265245699.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:61703 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbZGGFvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 01:51:46 -0400
Received: by fg-out-1718.google.com with SMTP id e12so811489fga.17
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2009 22:51:48 -0700 (PDT)
In-Reply-To: <20090706.182037.265245699.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My bad... will fix, test and resubmit ASAP.

On Tue, Jul 7, 2009 at 4:20 AM, David Miller<davem@davemloft.net> wrote:
>
> Your patch won't apply proprely.
>
> Your email client has corrupted the patch, turning TAB characters
> into spaces.
>
> Please see Documentation/email-clients.txt in the kernel tree
> so that you can learn how to properly send patches and not waste
> everyone's time.
>
> Thanks.
>
>
