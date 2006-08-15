From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [patch RFC 3/3] b44: convert to ssb module
Date: Tue, 15 Aug 2006 10:33:39 -0400
Message-ID: <20060815143331.GC28544@tuxdriver.com>
References: <200608150014.19661.mb@bu3sch.de> <200608150018.39548.mb@bu3sch.de>
	<20060815121248.GA28544@tuxdriver.com>
	<200608151614.16640.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200608151614.16640.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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

On Tue, Aug 15, 2006 at 04:14:16PM +0200, Michael Buesch wrote:

> You can take a look at the new DMA engine code of bcm43xx.
> It's the same engine.
> 
> BTW: John, I see that the new DMA engine code is not applied
> to wireless-dev (64-bit DMA and >1G support). But I think I
> already sent the patch. Where did it get lost? Was it my fault?

http://marc.theaimsgroup.com/?l=linux-netdev&m=115056542006772&w=2

Is this the patch?  I think this one is a victim of the "RFT" subject.
Oh, and the patch seemed to not be totally working based on this post:

	http://marc.theaimsgroup.com/?l=linux-netdev&m=115075858220477&w=2

Was there a newer version that I missed?  Did you still want the
older version applied anyway?

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
