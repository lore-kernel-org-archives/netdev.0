From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFT] remove skb_linearize from igmp.c
Date: Mon, 23 Jun 2003 13:17:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030623.131758.23035859.davem@redhat.com>
References: <20030623120342.470cf504.shemminger@osdl.org>
	<20030623.120229.59679308.davem@redhat.com>
	<20030623124118.620f8339.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030623124118.620f8339.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Mon, 23 Jun 2003 12:41:18 -0700

   Try again... this time add pullup logic to the query processing, and
   use skb_checksum to handle non-linear buffers.
   
I'll let this one sit for a day or so in order to get some
testing done :-)
