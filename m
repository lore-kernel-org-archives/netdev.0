From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [BK PATCH] Make eth.c independent of dev->hard_header_len
Date: Sun, 29 Sep 2002 14:45:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D974A3D.40207@pobox.com>
References: <Pine.LNX.4.44.0209291325460.28578-100000@chaos.physics.uiowa.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kai Germaschewski <kai-germaschewski@uiowa.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kai Germaschewski wrote:
> --- a/drivers/net/hamachi.c	Sun Sep 29 13:10:36 2002
> +++ b/drivers/net/hamachi.c	Sun Sep 29 13:10:36 2002

I would prefer to keep the code inside TX_CHECKSUM in hamachi.c, hoping 
somebody will complete it, not rip it out :)
