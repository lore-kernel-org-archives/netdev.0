From: "Masayuki Ohtake" <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [MeeGo-Dev] can: How to set bitrate
Date: Tue, 19 Oct 2010 09:09:41 +0900
Message-ID: <000c01cb6f21$f0a6ac90$66f8800a@maildom.okisemi.com>
References: <000b01cb6eb3$1afcfd60$66f8800a@maildom.okisemi.com>
	<4CBC29E6.3070601@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"Foster, Margie" <margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	ML netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ML linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, "Wang,
	Yong Y" <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Ewe, Kok Howg" <kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel OTC <joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tomoya MORINAGA <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, "Wang, Qi" <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
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

On Monday, October 18, 2010 8:05 PM, Wolfgang Grandegger wrote:

> ~$ rpm -qf /usr/include/db_185.h
> db4-devel-4.7.25-13.fc12.i686
>
> Which means you need db4 devel to fully build iproute2.

Thank you for your information.

Using the following command,
"yum install db4*"
I could confirm building iproute2 is success and
set bitrate.

Thanks, Ohtake(OKISemi)
