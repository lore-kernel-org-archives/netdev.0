From: Jeff Garzik <jgarzik@pobox.com>
Subject: build breakage
Date: Mon, 07 Mar 2005 02:59:57 -0500
Message-ID: <422C09FD.3000702@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
        "David S. Miller" <davem@davemloft.net>, Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Upstream net changes caused this to appear..

   CC      drivers/net/appletalk/cops.o
In file included from drivers/net/appletalk/cops.c:70:
include/linux/atalk.h:67: error: field `sk' has incomplete type
make[3]: *** [drivers/net/appletalk/cops.o] Error 1
make[2]: *** [drivers/net/appletalk] Error 2
