From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.5.70] e100 initialize fields prior to register_netdevice
Date: Thu, 29 May 2003 20:09:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ED6A124.1060704@pobox.com>
References: <Pine.LNX.4.44.0305291643550.23177-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
   "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <Pine.LNX.4.44.0305291643550.23177-100000@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Your patch doesn't apply at all, even with 'patch -l'.

I backed out Stephen's patch, and will be looking for a fix from you ;-)

	Jeff
