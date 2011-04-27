From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Wed, 27 Apr 2011 15:34:04 +0200
Message-ID: <4DB81B4C.9050404@grandegger.com>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>	<1303474267-6344-2-git-send-email-subhasish@mistralsolutions.com>	<4DB1A3B7.7060300@pengutronix.de>
	<4DB5D452.9050500@grandegger.com>	<46D523E49EFF489F9B088AE7B9CD7286@subhasishg>
	<4DB81A12.1000006@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, m-watkins-l0cyMroinI0@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4DB81A12.1000006-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

On 04/27/2011 03:28 PM, Wolfgang Grandegger wrote:
> On 04/27/2011 03:08 PM, Subhasish Ghosh wrote:
>>>
>>> - Use just *one* value per sysfs file
>>
>> SG - I felt adding entry for each mbx_id will clutter the sysfs.
>>        Is it ok to do that.
> 
> No, see:
> 
> http://lxr.linux.no/#linux+v2.6.38/Documentation/filesystems/sysfs.txt#L56

s/No/Yes/

Sorry for the confusion.

Wolfgang.
