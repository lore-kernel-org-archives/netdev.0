From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] (0/9) free_netdev -- delay freeing of net_device structure
 till after last use
Date: Tue, 19 Aug 2003 16:13:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F4284E6.7070709@pobox.com>
References: <20030819121800.009db89b.shemminger@osdl.org> <20030819124818.476dc36d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
   mochel@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030819124818.476dc36d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Yes, but drivers that want to work with all 2.4.x trees
> will need some kind of define to tip off of.  Just providing
> a HAVE_FREE_NETDEV ought to be sufficient.
> 
> Jeff?


Yeah, that works for me.

	Jeff
