From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.5.70-bk9: no IPsec modules are autoloaded
Date: Thu, 05 Jun 2003 05:12:38 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030605.051238.74748591.davem@redhat.com>
References: <29980000.1054812100@klopffest.muc.aerasec.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pb@bieringer.de
In-Reply-To: <29980000.1054812100@klopffest.muc.aerasec.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Dr. Peter Bieringer" <pb@bieringer.de>
   Date: Thu, 05 Jun 2003 13:21:40 +0200
   
   Sure known that autoloading of IPsec modules is broken...is this a bug or 
   by design?

You (or someone) has to add the appropriate entries to
/etc/modules.conf
