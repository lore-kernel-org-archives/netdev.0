From: "David S. Miller" <davem@redhat.com>
Subject: Re: ip_gre.c:ipgre_tunnel_xmit() duplicated code ?
Date: Mon, 21 Apr 2003 23:43:03 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030421.234303.59654654.davem@redhat.com>
References: <20030418.034241.38698733.davem@redhat.com>
	<200304211021.LAA21942@gw.chygwyn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve@ChyGwyn.com, steve@gw.chygwyn.com
In-Reply-To: <200304211021.LAA21942@gw.chygwyn.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Steven Whitehouse <steve@gw.chygwyn.com>
   Date: Mon, 21 Apr 2003 11:21:59 +0100 (BST)

   I found some code in ip_gre.c which looks to be duplicated. Is the
   attached the right fix or did I miss something? 

You're right, I've integrated your fix thanks.
