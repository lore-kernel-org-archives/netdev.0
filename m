From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPV6] compile fix for net/ipv6/route.c in current bk
Date: Sat, 17 May 2003 22:13:56 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030517.221356.88501530.davem@redhat.com>
References: <Mutt.LNX.4.44.0305181227260.21143-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0305181227260.21143-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Sun, 18 May 2003 12:29:53 +1000 (EST)

   This version of the ip6_null_entry initializer is needed for complation to 
   succeed with gcc version 2.96 20000731 (Red Hat Linux 7.3 2.96-110).
   
I know, thanks.  I have a fix in my tree from Arnaldo.
Aparently only gcc-3.x eats this construct I used :-)
