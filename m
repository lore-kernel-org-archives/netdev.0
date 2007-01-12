From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH V2] bcm43xx: Fix failure to deliver PCI-E interrupts
Date: Fri, 12 Jan 2007 20:01:45 +0100
Message-ID: <200701122001.45546.mb@bu3sch.de>
References: <45a7ceb2.m02aaCgouBsadVk/%Larry.Finger@lwfinger.net>
	<9b3e2dc20701121050p52e13d92r1ec78e1881bbed3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: "Stephen Sinclair" <radarsat1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
In-Reply-To: <9b3e2dc20701121050p52e13d92r1ec78e1881bbed3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Friday 12 January 2007 19:50, Stephen Sinclair wrote:
> > The PCI-E modifications to bcm43xx do not set up the interrupt vector
> > correctly. Tested with BCM4311 (PCI-E) on x86_64 and BCM4306 (PCI) on i386.
> 
> This was successful for me.  My 4311 is now getting interrupts, and I
> was able to successfully associate with an AP.  (i386)

That does the (i386) mean here?
Were you able to accociate with your PCI or PCI-E card?

-- 
Greetings Michael.
