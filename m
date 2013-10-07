From: Oussama Ghorbel <ou.ghorbel@gmail.com>
Subject: Re: [PATCH] Fix the upper MTU limit in ipv6 GRE tunnel
Date: Mon, 7 Oct 2013 18:52:15 +0100
Message-ID: <CABfLueFg=tKUbZPvKFKJZviNE+x1K4akjY8aPX7otyf_9gkLQQ@mail.gmail.com>
References: <1380880333-3546-1-git-send-email-ou.ghorbel@gmail.com>
	<20131007.125326.895480090584703586.davem@davemloft.net>
	<CABfLueGqa8wJv+hfcNQRmWM2tj6zMC5Ajts=-no7GJA1t09dnQ@mail.gmail.com>
	<20131007.133849.1821189531065820610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f41.google.com ([209.85.128.41]:50331 "EHLO
	mail-qe0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300Ab3JGRwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 13:52:15 -0400
In-Reply-To: <20131007.133849.1821189531065820610.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for that. I've added  it and I have resubmitted the patch.

Thanks

On Mon, Oct 7, 2013 at 6:38 PM, David Miller <davem@davemloft.net> wrote:
> From: Oussama Ghorbel <ou.ghorbel@gmail.com>
> Date: Mon, 7 Oct 2013 18:34:53 +0100
>
>> OK, I've resubmitted the patch with the proper Subject line.
>> The new mail subject is: [PATCH] ipv6: Fix the upper MTU limit in GRE tunnel
>
> You forgot to propagate the "Acked-by: " tag that was given by
> reviewers of your patch.
