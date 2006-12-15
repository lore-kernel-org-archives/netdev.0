From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 1/2] d80211: Turn PHYmode list from an array into a linked
	list
Date: Fri, 15 Dec 2006 15:33:07 +0100
Message-ID: <200612151533.07350.mb@bu3sch.de>
References: <200612141920.11439.mb@bu3sch.de> <200612151454.55508.mb@bu3sch.de>
	<20061215150655.50a728c4@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
In-Reply-To: <20061215150655.50a728c4-IhiK2ZEFs2oCVLCxKZUutA@public.gmane.org>
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

On Friday 15 December 2006 15:06, Jiri Benc wrote:
> On Fri, 15 Dec 2006 14:54:55 +0100, Michael Buesch wrote:
> > Can you also apply the bcm43xx fix for this to your tree?
> > I think that should be easiest and prevent long-living breakage.
> 
> It doesn't apply :-( It's probably easy to fix but I'd rather leave it
> to you to not make any damage.

Uh, yeah. Possible. It's diffed against my tree. Forgot that
I have some other changes in there.
I will resend a fixed fix :)

-- 
Greetings Michael.
