From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH 3/4] powerpc/p1010: FlexCAN Controller for of_ type
Date: Tue, 09 Aug 2011 12:37:13 +0200
Message-ID: <4E410DD9.40500@grandegger.com>
References: <1312815640-25804-1-git-send-email-bhaskar.upadhaya@freescale.com>
	<4E3FFEEB.8070400@pengutronix.de>
	<9C64B7751C3BCA41B64A68E23005A7BE1BF197@039-SN1MPN1-004.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linuxppc-release-50dRxjG7WBCY5r8RbUyfqNHuzzzSOjJt@public.gmane.org"
	<linuxppc-release-50dRxjG7WBCY5r8RbUyfqNHuzzzSOjJt@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <9C64B7751C3BCA41B64A68E23005A7BE1BF197-TcFNo7jSaXM0vywKSws3iq4g8xLGJsHaLnY5E4hWTkheoWH0uzbU5w@public.gmane.org>
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

On 08/09/2011 12:29 PM, U Bhaskar-B22300 wrote:
> 
> 
>> -----Original Message-----
>> From: Marc Kleine-Budde [mailto:mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org]
>> Sent: Monday, August 08, 2011 8:51 PM
>> To: U Bhaskar-B22300
>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; holt-sJ/iWh9BUns@public.gmane.org; wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org;
>> davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; linuxppc-release-50dRxjG7WBCY5r8RbUyfqNHuzzzSOjJt@public.gmane.org; U Bhaskar-
>> B22300; socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
>> Subject: Re: [PATCH 3/4] powerpc/p1010: FlexCAN Controller for of_ type
>>
>> On 08/08/2011 05:00 PM, Bhaskar Upadhaya wrote:
>>> Provide FlexCAN support for Freescale P1010 SoC.
>>> Modify the existing FlexCAN, so as to support the of_type approach on
>>> P1010(power architecture based)SoC.
>>>
>>> FlexCAN is a communication controller implementing the CAN protocol
>>> according to the CAN 2.0B protocol specification.
>>> This controller is available on Freescale P1010 platform.
>>> Signed-off-by: Bhaskar Upadhaya <bhaskar.upadhaya-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>>
>> NACK - your patch does more than the description states (debug code).
> [Bhaskar] Ok I will change description as below
> 	This patch introduces the following features
> 	1. provides the support for FlexCAN on P1010 SoC.
> 	2. Provides the common read/write interface for ARM and PowerPC based FlexCAN.
> 	3. Provides the clock interface for PowerPC based FlexCAN.
> 	Will it be OK ?

Sorry, too late. Please try the patches posted by Robin recently. We are
currently reviewing those for mainline inclusion and would be happy, if
you would help.

Thanks,

Wolfgang.
