From: "David S. Miller" <davem@redhat.com>
Subject: Re: Regarding SET_NETDEV_DEV
Date: Tue, 03 Jun 2003 20:09:44 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030603.200944.78736971.davem@redhat.com>
References: <20030603175921.GE2079@gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <20030603175921.GE2079@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jeff Garzik <jgarzik@pobox.com>
   Date: Tue, 3 Jun 2003 13:59:21 -0400

   For janitors and other developers placing this in net drivers...
   please don't :)  This can be done in upper layers, accomplishing the
   same goal without changing the low-level net driver code at all.
   
Don't say something can be done without showing exactly
how :-)

How does register_netdevice() know that the device is "whatever" and
where to get the generic device struct from?
