From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: Please pull bcm43xx-d80211 bugfixes and new features
Date: Tue, 3 Oct 2006 16:48:04 +0200
Message-ID: <200610031648.04932.mb@bu3sch.de>
References: <200610021843.20694.mb@bu3sch.de> <200610031358.33760.mb@bu3sch.de>
	<45227569.6070901@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <45227569.6070901-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
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

On Tuesday 03 October 2006 16:36, Larry Finger wrote:
> Michael Buesch wrote:
> >> kernel: bcm43xx_d80211: firmware revision FE84, patchlevel 90B4, date 2000-14-248
> >>   29:46:18
> > 
> > Uhm, which firmware are you running?
> 
> The softmac version reports the following (The "loaded" messages are something I'm trying.):
> 
> kernel: bcm43xx: Firmware: Microcode "bcm43xx_microcode4.fw" loaded.
> kernel: bcm43xx: Firmware: PCM "bcm43xx_pcm4.fw" loaded.
> kernel: bcm43xx: Firmware: InitVals0 "bcm43xx_initval01.fw" loaded.
> kernel: bcm43xx: Microcode rev 0x123, pl 0x21 (2005-01-22  19:48:06)

Well, so now you know where the problem is.
I can't debug this for you ;)

-- 
Greetings Michael.
