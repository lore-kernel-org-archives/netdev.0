From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] add prefetch to skb_queue_walk
Date: Thu, 19 Jun 2003 12:34:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030619.123459.35669634.davem@redhat.com>
References: <20030619121325.0a2059ee.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030619121325.0a2059ee.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Thu, 19 Jun 2003 12:13:25 -0700

   skb_queue_walk macro can use prefetch's  (like list_for_each)
   
Applied, thanks.
