From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.5.70] remove if_port_text
Date: Thu, 29 May 2003 18:07:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ED684BA.4070001@pobox.com>
References: <20030529.140828.78714529.davem@redhat.com>	<20030529142820.5f657d77.shemminger@osdl.org>	<3ED67E01.6060906@pobox.com> <20030529.144853.88480047.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, scott.feldman@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030529.144853.88480047.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Jeff Garzik <jgarzik@pobox.com>
>    Date: Thu, 29 May 2003 17:39:13 -0400
> 
>    Stephen Hemminger wrote:
>    > Eliminate necrophilic code, net-sysfs shouldn't support
>    > deprecated if_port.  Since nowhere else is using if_port_text,
>    > eliminate it.
>    
>    Looks good to me...  David?
>    
> I'm fine with it.  I'll apply to 2.5.x
> 
> Jeff what do you think about 2.4.x?


I'd rather not... that's an ABI-visible thing.

	Jeff
