From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Constant errors with pktgen
Date: Wed, 16 Mar 2005 14:50:20 -0800
Message-ID: <20050316145020.3ee45a69.davem@davemloft.net>
References: <20050314133404.2528647f@es175>
	<16951.422.818446.117190@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: cliffw@osdl.org, Robert.Olsson@data.slu.se, netdev@oss.sgi.com
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16951.422.818446.117190@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 16:39:18 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> 
> cliff white writes:
> 
>  > My test rig is two machines with an e100 card, connected by crossover 
>  > cable.
>  > 
>  > When i run pktgen, the error counter == packet count, always. 
> 
>  I see. Try the patch patch below it cleans up the code a bit and
>  restores the old meaning of error. It also has the minor fix from 
>  Adrian Bunk

Applied, thanks Robert.
