From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.5.70] e100 report link speed via if_port
Date: Thu, 29 May 2003 16:49:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ED67256.9040200@pobox.com>
References: <20030529104138.751a1f54.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
   Scott Feldman <scott.feldman@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030529104138.751a1f54.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dev->if_port is deprecated.  that's what ethtool is for... :)

	Jeff
