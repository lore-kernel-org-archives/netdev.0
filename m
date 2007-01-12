From: "Stephen Sinclair" <radarsat1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V2] bcm43xx: Fix failure to deliver PCI-E interrupts
Date: Fri, 12 Jan 2007 13:50:44 -0500
Message-ID: <9b3e2dc20701121050p52e13d92r1ec78e1881bbed3@mail.gmail.com>
References: <45a7ceb2.m02aaCgouBsadVk/%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: "Larry Finger" <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <45a7ceb2.m02aaCgouBsadVk/%Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

> The PCI-E modifications to bcm43xx do not set up the interrupt vector
> correctly. Tested with BCM4311 (PCI-E) on x86_64 and BCM4306 (PCI) on i386.

This was successful for me.  My 4311 is now getting interrupts, and I
was able to successfully associate with an AP.  (i386)


Steve
