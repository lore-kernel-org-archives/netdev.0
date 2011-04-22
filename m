From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [RFC v3 5/6] j1939: rename NAME to UUID?
Date: Fri, 22 Apr 2011 17:14:14 +0200
Message-ID: <4DB19B46.4000306@hartkopp.net>
References: <20110314132004.GA333@e-circ.dyndns.org>
	<20110314135917.GF333@e-circ.dyndns.org>
	<4D8623BE.2080807@hartkopp.net>
	<20110413044928.GA289@kurt.e-circ.dyndns.org>
	<4DA88705.5040203@hartkopp.net>
	<20110420072439.GB332@kurt.e-circ.dyndns.org>
	<20110422141832.GB334@kurt.e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110422141832.GB334-ozGf4kBk5synFtIcQ8t7k3L8HoS0Hn3T@public.gmane.org>
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

On 22.04.2011 16:18, Kurt Van Dijck wrote:
> On Wed, Apr 20, 2011 at 09:24:39AM +0200, Kurt Van Dijck wrote:
>> I need to git pull the latest updates, and I'll send a revised patchset
>> tomorrow.
> Oliver,
> 
> I did not forget, but something came in between. next week for sure.

Oh, no problem.

I'm constantly working on my reply to your latest answer 8-)

BTW: Do you have any sample code that shows, how the sending (and receiving)
of the same BAM message would look like in the static and in the
address-claimed case?? I'm not really able to extract this information from
your posted documentation.

I would like to know

- what has to be configured before (from the user and the admin)
- how does the application source code look like in the requested four cases

I think we're a bit stuck in the discussion of the 'easy to use' socket API
without having real-world examples.

Thanks,
Oliver
