From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next] can: add can_free_echo_skb() for upcoming drivers
Date: Fri, 04 Sep 2009 16:34:45 +0200
Message-ID: <4AA12585.2090103@grandegger.com>
References: <4A9D3D14.90201@grandegger.com>	<20090903.204641.193482962.davem@davemloft.net>	<4AA0C692.5000003@grandegger.com>
	<20090904.021350.234672852.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20090904.021350.234672852.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/04/2009 11:13 AM, David Miller wrote:
> From: Wolfgang Grandegger<wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> Date: Fri, 04 Sep 2009 09:49:38 +0200
>
>> David Miller wrote:
>>> Can a CAN expert please review these patches?  They are rotting
>>> in patchwork and I want to move forward with them somehow.I'
>>
>> I'm maintaining the CAN device drivers interface and drivers as listed
>> in MAINTAINERS. Though, these patches have already the official blessing.
>
> My bad :-)  I'll apply these then.
>
>> Do you want me to setup a git repository "can-next-2.6" where you can
>> pull from? So far, not that much can-drv patches have been posted to
>> this list.
>
> You can do that in the future if you like, sure.  But it is not a
> requirement, as with the rate you guys send things I am handling it
> efficiently using patchwork.

OK, then I will continue sending patches for the time being. Please let 
me know when a git repository would ease your work.

Thanks,

Wolfgang.
