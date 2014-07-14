From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: filter: sk_chk_filter() no longer
 mangles filter
Date: Sun, 13 Jul 2014 23:28:14 -0700 (PDT)
Message-ID: <20140713.232814.1618910912826730440.davem@davemloft.net>
References: <CAADnVQLQR9fYVGfxfnwpirXt4CwBUzr36tJL+aEoo0err7cppw@mail.gmail.com>
	<53C10C8A.70706@redhat.com>
	<1405172956.3515.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, alexei.starovoitov@gmail.com,
	develop@kristov.de, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org, paulus@samba.org, isdn@linux-pingi.de
To: eric.dumazet@gmail.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1405172956.3515.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 12 Jul 2014 15:49:16 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Add const attribute to filter argument to make clear it is no
> longer modified.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
