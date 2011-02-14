From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH v2 09/13] can: pruss CAN driver.
Date: Mon, 14 Feb 2011 08:42:07 +0100
Message-ID: <20110214074206.GA374@e-circ.dyndns.org>
References: <1297435892-28278-1-git-send-email-subhasish@mistralsolutions.com>
	<1297435892-28278-10-git-send-email-subhasish@mistralsolutions.com>
	<20110211150602.GB373@e-circ.dyndns.org>
	<C1C4300CE90A406FBDA2388D5491FAD5@subhasishg>
	<4D58D854.5090503@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	CAN NETWORK DRIVERS <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, m-watkins-l0cyMroinI0@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D58D854.5090503-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

On Mon, Feb 14, 2011 at 08:23:00AM +0100, Wolfgang Grandegger wrote:
> On 02/14/2011 05:54 AM, Subhasish Ghosh wrote:
> > Hello,
> > 
> > I had a discussion regarding this with Wolfgang:
> > 
> > http://www.mail-archive.com/socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org/msg00324.html
> > 
> > The problem here is that we must configure the mailbox ID's and this
> > support is not available in the socketCan sub-system.
> 
> Using SysFS files would already be much better.
Ack.

Kurt
