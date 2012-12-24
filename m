From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: Re: [PATCH] net,
	batman: don't crash on zero length strings in routing_algo
Date: Mon, 24 Dec 2012 22:38:22 +0800
Message-ID: <201212242238.23255.lindner_marek@yahoo.de>
References: <1353355695-23252-1-git-send-email-sasha.levin@oracle.com>
 <CANiGF9-_roU2oD5uTRvjvaS5=bv-VoRBdULZN3PtgFzs5z1=CQ@mail.gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pau Koning <paukoning-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org,
 Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <CANiGF9-_roU2oD5uTRvjvaS5=bv-VoRBdULZN3PtgFzs5z1=CQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Monday, December 24, 2012 22:18:52 Pau Koning wrote:
> On Mon, Nov 19, 2012 at 9:08 PM, Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> > The code that works with routing_algo assumes that the string passed is
> > non
> 
> > empty, this assumption is wrong:
> Why isn't this patch part of Linux 3.7? It seems to be a bugfix and it
> was sent early enough?

The patch received a reply mere 2 hours after it was sent. Again, please read 
all mails before making noise.

Thanks,
Marek
