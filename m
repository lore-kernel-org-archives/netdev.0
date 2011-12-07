From: Hagen Paul Pfeifer <hagen-GvnIQ6b/HdU@public.gmane.org>
Subject: Re: Time in Queue, bufferbloat,
	and... our accidentally  interplanetary network
Date: Wed, 07 Dec 2011 11:19:29 +0100
Message-ID: <11877422e38eade300dd1cdb9e423d47@localhost>
References: <CAA93jw7kQYONQiAozatRmdRRJeK0GB9eNDWtRZ3AL+OVKn0OpA@mail.gmail.com>
	<1323082774.2670.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<9dfc3c5eb811f2774b378fce0158b3e7@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bloat-devel <bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	bloat <bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
To: Hagen Paul Pfeifer <hagen-GvnIQ6b/HdU@public.gmane.org>
Return-path: <bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
In-Reply-To: <9dfc3c5eb811f2774b378fce0158b3e7@localhost>
List-Unsubscribe: <https://lists.bufferbloat.net/options/bloat>,
	<mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/bloat>
List-Post: <mailto:bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
List-Help: <mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/bloat>,
	<mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=subscribe>
Sender: bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
Errors-To: bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
List-Id: netdev.vger.kernel.org


On Wed, 07 Dec 2011 11:15:38 +0100, Hagen Paul Pfeifer <hagen-GvnIQ6b/HdU@public.gmane.org>
wrote:
 
> Question two: I submitted pfast_head_drop to drop more outdated data
> instead of new data. Back in time I thought TCP _may_ experience
benefits
> because more up-to-date SACK data packets are saved. Are there any other
> TCP advantages with head drop policy?

Small comment: pfast_head_drop was intended for UDP. E.g. OLSR messages,
regular GPS reporting and the like. TCP was not the focus at that time.

HGN
