From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.69] net/ipv6 missing kmem_cache_destroy in module
 exit
Date: Tue, 13 May 2003 16:59:46 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030513.165946.35026472.davem@redhat.com>
References: <1052864772.2442.8.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
   jmorris@intercode.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: daniel@osdl.org
In-Reply-To: <1052864772.2442.8.camel@ibm-c.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Daniel McNeil <daniel@osdl.org>
   Date: 13 May 2003 15:26:13 -0700

   ipv6 is missing the calls to kmem_cache_destory() in module_exit
   and some cleanup routines.
   
Applied, thanks.
