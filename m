From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: mmotm 2010-09-28-16-13 uploaded
Date: Wed, 29 Sep 2010 08:01:13 -0700
Message-ID: <20100929080113.5581c19d.rdunlap@xenotime.net>
References: <201009282344.o8SNiliN024981@imap1.linux-foundation.org>
	<AANLkTinYExzihm6BuP=amLDwMO-zXejeUq5xeHL4ETg_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "N.P.S. N.P.S." <napohybelskurwysynom2010@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinYExzihm6BuP=amLDwMO-zXejeUq5xeHL4ETg_@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2010 15:13:41 +0200 N.P.S. N.P.S. wrote:

> 2010/9/29  <akpm@linux-foundation.org>:
> > The mm-of-the-moment snapshot 2010-09-28-16-13 has been uploaded to
> 
> Another randconfig thing
> 
> drivers/net/pch_gbe/pch_gbe_main.c: In function 'pch_gbe_tx_queue':
> drivers/net/pch_gbe/pch_gbe_main.c:965: error: implicit declaration of
> function 'tcp_hdr'
> drivers/net/pch_gbe/pch_gbe_main.c:965: error: invalid type argument
> of '->' (have 'int')
> drivers/net/pch_gbe/pch_gbe_main.c:968: error: invalid type argument
> of '->' (have 'int')
> drivers/net/pch_gbe/pch_gbe_main.c:976: error: implicit declaration of
> function 'udp_hdr'
> drivers/net/pch_gbe/pch_gbe_main.c:976: error: invalid type argument
> of '->' (have 'int')
> drivers/net/pch_gbe/pch_gbe_main.c:980: error: invalid type argument
> of '->' (have 'int')
> make[3]: *** [drivers/net/pch_gbe/pch_gbe_main.o] Error 1
> make[2]: *** [drivers/net/pch_gbe] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2

Patch has been sent to DaveM and he has merged it.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
