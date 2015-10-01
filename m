From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute2 compatibility
Date: Thu, 01 Oct 2015 13:48:24 -0700
Message-ID: <1443732504.32531.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAOxq_8MPyWbPLeNWyEiSwq9xXgHwSXm29T3849HLmOg3Z7TXuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34155 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146AbbJAUs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 16:48:27 -0400
Received: by padhy16 with SMTP id hy16so84809711pad.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 13:48:26 -0700 (PDT)
In-Reply-To: <CAOxq_8MPyWbPLeNWyEiSwq9xXgHwSXm29T3849HLmOg3Z7TXuw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-01 at 13:06 -0700, Ani Sinha wrote:
> Hi Stephen :
> 
> I was looking around but could not find clear evidence that a later
> version of iproute2 is compatible with an older kernel. Specifically,
> we are wondering if iproute2 v 3.6 is compatible with linux kernel
> 3.4. Highly appreciate any pointers on this.

We try hard to keep iproute2 compatible with all kernels.
