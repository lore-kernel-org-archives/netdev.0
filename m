From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2 1/2] can: add driver for Softing card
Date: Fri, 7 Jan 2011 13:29:18 +0100
Message-ID: <20110107122918.GB324@e-circ.dyndns.org>
References: <20110104150513.GA321@e-circ.dyndns.org>
	<20110104150759.GB321@e-circ.dyndns.org>
	<4D24DB2C.9040104@grandegger.com>
	<20110106150525.GB324@e-circ.dyndns.org>
	<4D25ED70.7000303@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D25ED70.7000303-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

On Thu, Jan 06, 2011 at 05:27:28PM +0100, Wolfgang Grandegger wrote:
> >> - Please avoid alignment of expressions and structure members.
> 
I agree with most of them.
The alignment of register offset macro's is 1 thing I intend to
keep as is ...
Maybe I put a comment in front to explain why it's aligned...

Kurt
> 
