From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] wanrouter/wanmain: fix namespace, fixing the current
 problem with device_shutdown
Date: Thu, 22 May 2003 00:53:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522.005354.02291716.davem@redhat.com>
References: <20030521171441.GA10295@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030521171441.GA10295@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Wed, 21 May 2003 14:14:41 -0300

   bk://kernel.bkbits.net/acme/net-2.5
   
   	This makes wanrouter build again after device_shutdown was added to
   linux/device.h, that ends up clashing with the non-namespaced function in
   wanmain.c.

Pulled, thanks Arnaldo.
