From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Use new kconfig 'select' for networking crypto
Date: Tue, 03 Jun 2003 22:49:25 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030603.224925.68063710.davem@redhat.com>
References: <Mutt.LNX.4.44.0306041222190.28457-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@digeo.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0306041222190.28457-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Wed, 4 Jun 2003 12:28:50 +1000 (EST)

   The patch below against recent bk uses the new 'select' feature of
   kconfig to configure crypto features for ipsec and ipv6 privacy
   extensions.
   
   This should solve a lot of the build problems people have been
   having, and it also enables the crypto submenu (which previously
   did not work).

Applied, thanks a lot James.
