From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: IPv6 went away?
Date: Mon, 14 Mar 2005 18:18:18 -0500
Message-ID: <42361BBA.5050409@pobox.com>
References: <42361510.2080902@pobox.com> <20050314150151.0a2abda6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>, yoshfuji@wide.ad.jp
In-Reply-To: <20050314150151.0a2abda6.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Mon, 14 Mar 2005 17:49:52 -0500
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>Has anything major been done to ipv6 recently?
> 
> 
> Yes, it was changed with several updates from USAGI to
> make it pass the "ipv6 ready" requirements.  The
> experimental Kconfig tag was also removed, perhaps for this
> reason it was not included in your build?

Nevermind, a route didn't come up on my side.  My apologies for wasting 
everybody's time.

6to4 and IPv6 appear to be working just fine, good work everyone :)

	Jeff
