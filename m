From: Tino Keitel <tino.keitel@alcnetworx.de>
Subject: Re: BQL support in gianfar causes network hickup
Date: Mon, 27 May 2013 14:47:12 +0200
Message-ID: <1369658832.4182.23.camel@keitelt1-d1.lawo.de>
References: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de>
	 <50AFA599.9040108@windriver.com> <loom.20121124T213422-650@post.gmane.org>
	 <1353800616.2590.4562.camel@edumazet-glaptop>
	 <20121126100111.GA3728@mac.home> <1353947677.7553.2.camel@edumazet-glaptop>
	 <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6F@Exchange1.lawo.de>
	 <1353950255.7553.6.camel@edumazet-glaptop>
	 <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE70@Exchange1.lawo.de>
	 <1354019816.7553.1585.camel@edumazet-glaptop>
	 <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE71@Exchange1.lawo.de>
	 <1354023162.7553.1708.camel@edumazet-glaptop>
	 <9AA65D849A88EB44B5D9B6A8BA098E23042DCF04C8BB@Exchange1.lawo.de>
	 <CAP=VYLrbFz4UBMthg+FOqc4g0jW_4=etE+jJK6YE_EaSj8cNLA@mail.gmail.com>
	 <9AA65D849A88EB44B5D9B6A8BA098E23042DCF04C8BE@Exchange1.lawo.de>
	 <517E722D.4060808@freescale.com>
	 <1367241659.6393.30.camel@keitelt1-d1.lawo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tino Keitel <tino.keitel@tikei.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.lawo.de ([80.149.95.33]:17984 "EHLO mail2.lawo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932203Ab3E0Mrd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 08:47:33 -0400
In-Reply-To: <1367241659.6393.30.camel@keitelt1-d1.lawo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 2013-04-29 at 15:20 +0200, Tino Keitel wrote:
> On Mo, 2013-04-29 at 15:14 +0200, Claudiu Manoil wrote:
> 
> > The proposed fix (passes this test):
> > http://patchwork.ozlabs.org/patch/240365/
> > 
> > Does it work for you?

Hi,

I tested the patch over the weekend and it looks fine. I then re-checked
without the patch and got the bug immediately. So the patch seems to
work fine.

Thanks a lot and regards,
Tino Keitel
