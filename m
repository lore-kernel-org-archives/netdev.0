From: Martin Langer <martin-langer-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: Please pull bcm43xx-d80211 bugfixes and new features
Date: Tue, 3 Oct 2006 14:36:21 +0200
Message-ID: <20061003123621.GA4673@tuba>
References: <200610021843.20694.mb@bu3sch.de> <4521DCBB.2030201@lwfinger.net>
	<200610031358.33760.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200610031358.33760.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 03, 2006 at 01:58:33PM +0200, Michael Buesch wrote:
> On Tuesday 03 October 2006 05:44, Larry Finger wrote:
> > 
> > kernel: ssb: Core 0 found: cc 0800, rev 02, vendor 4243
> > kernel: ssb: Core 1 found: cc 0812, rev 04, vendor 4243
> > kernel: ssb: Core 2 found: cc 080D, rev 01, vendor 4243
> > kernel: ssb: Core 3 found: cc 0807, rev 01, vendor 4243
> > kernel: ssb: Core 4 found: cc 0804, rev 07, vendor 4243
> > kernel: ssb: Core 5 found: cc 0812, rev 04, vendor 4243
> > kernel: bcm43xx_d80211: Ignoring additional 802.11 core.
> > kernel: bcm43xx_d80211: Broadcom 4306 WLAN found
> > kernel: ssb: Switching to core 4
> > kernel: bcm43xx_d80211: PHY connected
> > kernel: ssb: Switching to core 1
> > kernel: bcm43xx_d80211: Detected PHY: Version: 1, Type 2, Revision 1
> > kernel: bcm43xx_d80211: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
> > kernel: bcm43xx_d80211: Radio turned off
> > kernel: bcm43xx_d80211: Radio turned off
> > kernel: wmaster0: Selected rate control algorithm 'simple'
> > kernel: bcm43xx_d80211: Virtual interface added (type: 0x00000002, ID: 4, MAC: 00
> > :06:25:40:6f:03)
> > kernel: bcm43xx_d80211: PHY connected
> > kernel: bcm43xx_d80211: PHY disconnected
> > kernel: bcm43xx_d80211: PHY connected
> > kernel: bcm43xx_d80211: firmware revision FE84, patchlevel 90B4, date 2000-14-248
> >   29:46:18
> 
> Uhm, which firmware are you running?

v4 testers should use the SVN version of fwcutter. There was a v4 
windriver bug in fwcutter .... some time ago.

Martin
