From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [NET]: TSO requires SG, enforce this at device registry.
Date: Mon, 25 Oct 2004 02:28:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417C9D08.6030903@pobox.com>
References: <200410221715.i9MHFlIu021927@hera.kernel.org>	<417C9431.6030505@pobox.com> <20041024225700.4a22a968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041024225700.4a22a968.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Mon, 25 Oct 2004 01:50:41 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>1) Given current driver implementations of ethtool ioctls, sysadmin is 
>>free to create a combination of bits that are IMHO a bug.  One can argue 
>>that this is an extension of "root can shoot himself in the foot", so 
>>who knows.
> 
> 
> I made a followon posting proposing ethtool changes which
> would enforce the rules there too, did you see it?


Sorry, I didn't see it.  URL or grep string?

	Jeff
