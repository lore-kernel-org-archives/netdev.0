From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] af_pppox: create module infrastructure for protocol
 modules
Date: Mon, 28 Apr 2003 23:00:45 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030428.230045.21906184.davem@redhat.com>
References: <20030429061227.GJ25361@conectiva.com.br>
	<20030428.222728.48508327.davem@redhat.com>
	<20030429.154651.108798316.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, mostrows@speakeasy.net, netdev@oss.sgi.com,
   maxk@qualcomm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@wide.ad.jp
In-Reply-To: <20030429.154651.108798316.yoshfuji@wide.ad.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@wide.ad.jp>
   Date: Tue, 29 Apr 2003 15:46:51 +0900 (JST)

   We probably need to refer IPv4 module as well as IPv6 module 
   because of the IPv4-Mapped address feature for IPv6 sockets.
   
Right.
