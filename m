From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: RTL8139
Date: Mon, 15 Dec 2003 14:51:26 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FDE10BE.2000208@pobox.com>
References: <3FDDF085.6060603@secline.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leo Cambilargiu <leo@secline.com.br>
In-Reply-To: <3FDDF085.6060603@secline.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Leo Cambilargiu wrote:
> Hello readers:
> 
> I purchased a couple of encore ENL832-tx NIC's that Linux doesn't 
> recognize.
> 
> they are based on RTL8139C (06117S1)
> 
> The module 8139too (2.4.23) doesn't load.  It behaves as though no 
> recognized hardware exists.
> 
> Any comments?


Probably you need to add PCI ids to 8139too.c...
