From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [BRIDGE] Change bridge forwarding table to use hlist
Date: Tue, 29 Apr 2003 23:52:48 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429.235248.98885884.davem@redhat.com>
References: <20030429103524.15f56cbf.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030429103524.15f56cbf.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Tue, 29 Apr 2003 10:35:24 -0700

   Switch bridge functional table to using hlist_macros.  The code
   was using the same form of hash list already, this just uses the
   convient macros.  
   
Applied, thanks Stephen.
