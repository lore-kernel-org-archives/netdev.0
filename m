From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] can-raw: Fix skb_orphan_try handling
Date: Tue, 03 Aug 2010 19:50:27 +0200
Message-ID: <4C5856E3.3070606@hartkopp.net>
References: <4C529EFB.4090601@hartkopp.net>	
	<20100801.010337.68133932.davem@davemloft.net>	
	<4C555168.3090800@hartkopp.net>	
	<20100803.003056.216763358.davem@davemloft.net>	
	<4C583447.8010004@hartkopp.net>	
	<1280852081.3266.834.camel@pohly-mobl1.ikn.intel.com>	
	<4C584DB2.8020406@hartkopp.net>
	<1280856828.3266.839.camel@pohly-mobl1.ikn.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1280856828.3266.839.camel-/oqbx4SGF9pV+x+AlpbFz62pdiUAq4bhAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03.08.2010 19:33, Patrick Ohly wrote:
> On Tue, 2010-08-03 at 10:11 -0700, Oliver Hartkopp wrote:
>>> I'm fine with using a simple u8. I'm not sure where I picked up the
>>> union thing, it's not something that I usually do in my own code.
>>>
>>
>> :-)
>>
>> Im currently busy until next week, would you like to provide a patch?
> 
> Sorry, I have to pass. I'm busy elsewhere myself. MeeGo and
> SyncEvolution plus real life consume all of my time nowadays.

Working for MeeGo is a good excuse ;-)

Will pick that task next week.

BR,
Oliver
