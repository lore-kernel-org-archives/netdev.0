From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] netdev_ops
Date: Thu, 10 Jul 2003 00:42:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710.004207.35528695.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102229133@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: scott.feldman@intel.com
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102229133@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Feldman, Scott" <scott.feldman@intel.com>
   Date: Thu, 10 Jul 2003 00:47:13 -0700

   Can we get a HAVE_NETDEV_OPS?
   
Don't tell me you're seriously considering having _TWO_ copies
of all this code sitting around?

At that point backwards compat becomes absolutely rediculious.  If
it's important to you, just stick to the current scheme.  You gain
nothing by maintaining two copies of the same code.
