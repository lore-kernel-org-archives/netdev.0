From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] can: Add driver for SJA1000 based PCI CAN interface cards
	by esd
Date: Wed, 31 Mar 2010 19:05:53 +0200
Message-ID: <4BB380F1.3010909@grandegger.com>
References: <201003311428.05749.matthias.fuchs@esd.eu>	<4BB34F92.5010308@grandegger.com>
	<201003311617.50061.matthias.fuchs@esd.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201003311617.50061.matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
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

Matthias Fuchs wrote:
> Hi Wolfgang,
> 
> I am aware of the PCI PLX driver. It should be possible to
> adapt that one. It lacks PLX9056 support so it's not done by just
> adding some PCI device IDs.
> 
> But if that's how it should be done I will do so.

>From the maintenance point of view, that's the preferred solution.
Thanks for your effort.

Wolfgang.
