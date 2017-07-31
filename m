From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: xfrm hardware offload for AH
Date: Mon, 31 Jul 2017 08:40:14 +0200
Message-ID: <20170731064014.GT2631@secunet.com>
References: <CAA1sxtx-OZhnyq1hBaOVUu0URk5FuZMev8Y8ut-pCgBHtvdgFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David George <david.george@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:48874 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751696AbdGaGkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 02:40:16 -0400
Content-Disposition: inline
In-Reply-To: <CAA1sxtx-OZhnyq1hBaOVUu0URk5FuZMev8Y8ut-pCgBHtvdgFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David.

On Thu, Jul 20, 2017 at 10:03:54AM +0200, David George wrote:
> Hi Steffen
> 
> I am wondering if there would be any traction for adding xfrm hardware
> offload support for AH (something equivalent to esp4_offload). Is it
> something you have thought about?

I personally have no plans to add support for AH as this is not so
widely used anymore. But if you have a usecase, go for it. Patches are
welcome.
