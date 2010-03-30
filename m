From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] Add hotplug support to mcp251x driver
Date: Tue, 30 Mar 2010 09:23:35 +0200
Message-ID: <4BB1A6F7.1090600@grandegger.com>
References: <1269889076-5611-1-git-send-email-maz@misterjones.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Edwin Peer <epeer-edQ+oOd84Ub6AMQ9O9Cv5/d9D2ou9A/h@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Marc Zyngier <maz-20xNzvSXLT6hUMvJH42dtQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1269889076-5611-1-git-send-email-maz-20xNzvSXLT6hUMvJH42dtQ@public.gmane.org>
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

Marc Zyngier wrote:
> Chip model can now be selected directly by matching the modalias name
> (instead of filling the .model field in platform_data), and allows the
> module to be auto-loaded. Previous behaviour is of course still supported.
> 
> Convert the two in-tree users to this feature (icontrol & zeus).
> Tested on an Zeus platform (mcp2515).
> 
> Signed-off-by: Marc Zyngier <maz-20xNzvSXLT6hUMvJH42dtQ@public.gmane.org>
> Acked-by: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
> Cc: Edwin Peer <epeer-edQ+oOd84Ub6AMQ9O9Cv5/d9D2ou9A/h@public.gmane.org>

Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

for the Socket-CAN part.

Wolfgang.
