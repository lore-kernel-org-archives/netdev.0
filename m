From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] (8/8) loopback device simplification
Date: Wed, 03 Sep 2003 20:43:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F568AC0.5090601@pobox.com>
References: <20030903164921.7d923008.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030903164921.7d923008.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Would be nice to move dev_base and dev_base_lock somewhere, maybe 
drivers/net/net_init.c (which really should be renamed libnet.c) or 
perhaps somewhere in net/*
