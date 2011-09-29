From: Thomas Wiedemann <Thomas.Wiedemann-8kCRUXUQ4vU@public.gmane.org>
Subject: Antwort: Re: [PATCH net-next-2.6] can/sja1000: driver for PEAK PCAN
	PCI/PCIe cards
Date: Thu, 29 Sep 2011 13:46:36 +0200
Message-ID: <OF72B7C0BE.EE4FAB88-ONC125791A.004029CC-C125791A.004097EF@retarus.de>
References: <4E844AFB.3020201@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-g4cQ8AsIbFbL9ATBNaCtXw@public.gmane.org,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4E844AFB.3020201-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

Hi Wolfgang,
i just replaced peak_pci.c.
The net-next-2.6 branch? Is that the one in the latest linux kernels? I'll 
try to find some time to test a new kernel.

Thomas

Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org> schrieb am 29.09.2011 12:39:55:

> Hi Thomas,
> 
> On 09/29/2011 11:21 AM, Thomas Wiedemann wrote:
> > I got access to another system with a 4 channel card and tested your 
patch 
> > (v1) within the Berlios socket-can SVN tree: it worked :)
> 
> Hm, did the patch apply to the SVN tree? Any chance to test with David
> Miller's net-next-2.6 tree. Anyway, I'm quite sure now that the patch
> works fine on 4-channel cards as well.
> 
> Thanks for your effort.
> 
> Wolfgang.
