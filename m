From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: Antwort: Re: [PATCH net-next-2.6] can/sja1000: driver for PEAK
	PCAN	PCI/PCIe cards
Date: Thu, 29 Sep 2011 13:54:16 +0200
Message-ID: <4E845C68.7010203@grandegger.com>
References: <OF72B7C0BE.EE4FAB88-ONC125791A.004029CC-C125791A.004097EF@retarus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-g4cQ8AsIbFbL9ATBNaCtXw@public.gmane.org,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
To: Thomas Wiedemann <Thomas.Wiedemann-8kCRUXUQ4vU@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <OF72B7C0BE.EE4FAB88-ONC125791A.004029CC-C125791A.004097EF-Npw8gZsewqCELgA04lAiVw@public.gmane.org>
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

Hi Thomas,

On 09/29/2011 01:46 PM, Thomas Wiedemann wrote:
> Hi Wolfgang,
> i just replaced peak_pci.c.
> The net-next-2.6 branch? Is that the one in the latest linux kernels? I'll 
> try to find some time to test a new kernel.

Temporarily (kernel.org is still down) you can get the "net-next-2.6" as
shown below:

  $ git clone git://github.com/davem330/net-next.git

The tree is maintained by David Miller and will show up mainline with
the next kernel release.

Thanks,

Wolfgang.
