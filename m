From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [ANNOUNCE] netplug, a daemon that handles network cables getting
 plugged in and out
Date: Thu, 28 Aug 2003 17:35:49 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F4E75B5.4020401@pobox.com>
References: <1062105712.12285.78.camel@serpentine.internal.keyresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Bryan O'Sullivan" <bos@keyresearch.com>
In-Reply-To: <1062105712.12285.78.camel@serpentine.internal.keyresearch.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bryan O'Sullivan wrote:
> Netplug is a daemon that responds to network cables being plugged in or
> out by bringing a network interface up or down.  This is extremely
> useful for DHCP-managed systems that move around a lot, such as laptops
> and systems in cluster environments.
> 
> For more details and download instructions, see the netplug homepage:
> http://www.red-bean.com/~bos/


Does it make use of the link status notification stuff in 2.6.x?  ;-)

	Jeff
