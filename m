From: "Thibaut VARENE" <T-Bone@parisc-linux.org>
Subject: Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Tue, 9 Jan 2007 11:56:59 +0100
Message-ID: <7d01f9f00701090256q5d04094bs4d636b128a61bc29@mail.gmail.com>
References: <7d01f9f00701051103q3ee6ed35q9fd0f778a18061b8@mail.gmail.com>
	 <20070109092602.GC1703@ff.dom.local>
	 <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com>
	 <20070109105244.GD1703@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:26242 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbXAIK5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 05:57:01 -0500
Received: by ug-out-1314.google.com with SMTP id 44so6530681uga
        for <netdev@vger.kernel.org>; Tue, 09 Jan 2007 02:57:00 -0800 (PST)
To: "Jarek Poplawski" <jarkao2@o2.pl>
In-Reply-To: <20070109105244.GD1703@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/9/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
> On Tue, Jan 09, 2007 at 11:27:59AM +0100, Thibaut VARENE wrote:
> ...
> > I suspected both and changed both the disk and the ram for quality
> > parts, that I tested afterwards. Both passed thorough tests.
>
> You wrote about half an hour, so overheating was also
> considered, I presume.

Yes, but since it works fine with the other NIC... :)

> > Finally, using the other NIC on the box (a VIA Rhine II, 100Mbps),
> > works absolutely fine.
>
> So it looks like the card/driver (or maybe this specimen?).

I'm suspecting the driver, but I'm not a specialist :)
It's true that this particular card specimen could be damaged even
though that seems a bit unlikely.

HTH

T-Bone

-- 
Thibaut VARENE
http://www.parisc-linux.org/~varenet/
