From: Patrick McHardy <kaber@trash.net>
Subject: Re: More IPSEC trouble
Date: Thu, 10 Mar 2005 18:15:54 +0100
Message-ID: <423080CA.3060604@trash.net>
References: <Pine.LNX.4.61.0503101229380.18067@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Steve Hill <steve@services.navaho.net>
In-Reply-To: <Pine.LNX.4.61.0503101229380.18067@sorbus2.navaho>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Steve Hill wrote:
> 
> Unfortunately I've found another IPSEC kernel bug (2.6.10):
> 
> Increasing the packet size by 1 byte would obviously require 
> fragmentation of the encrypted packet and causes the machine to lock up.

Doesn't sound familiar to me, but I would recommend trying
2.6.11 anyway.

Regards
Patrick
