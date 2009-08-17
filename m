From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH -next] phonet: fix build when PROC_FS is disabled
Date: Mon, 17 Aug 2009 23:43:43 +0300
Message-ID: <200908172343.44744.remi@remlab.net>
References: <4A89BF25.9010404@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"linux-next" <linux-next@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4A89BF25.9010404@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 17 ao=FBt 2009 23:35:49 Randy Dunlap, vous avez =E9crit :
> From: Randy Dunlap <randy.dunlap@oracle.com>
>
> Fix phonet build when PROC_FS is not enabled:
>
> net/built-in.o: In function `pn_sock_open':
> socket.c:(.text+0x23c649): undefined reference to `seq_open_net'
> net/built-in.o:(.rodata+0x21018): undefined reference to `seq_release=
_net'
>
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Acked-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>


--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
