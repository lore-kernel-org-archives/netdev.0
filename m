From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.69] pktgen module and dev cleanup
Date: Thu, 08 May 2003 08:37:37 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030508.083737.57463230.davem@redhat.com>
References: <20030507142911.4a8a7573.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030507142911.4a8a7573.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Wed, 7 May 2003 14:29:11 -0700
   
   Fix pktgen so the /proc interface uses owner instead of inc/dec the
   module ref count itself.  Gets rid of warnings, and properly ref counts
   all readers/writers now.

Applied, thanks a lot Stephen.
