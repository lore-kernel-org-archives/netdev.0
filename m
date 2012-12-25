From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: Re: [PATCH] net,
	batman: don't crash on zero length strings in routing_algo
Date: Tue, 25 Dec 2012 16:30:42 +0800
Message-ID: <201212251630.42980.lindner_marek@yahoo.de>
References: <1353355695-23252-1-git-send-email-sasha.levin@oracle.com>
 <CANiGF9_engsHHNUDnJi6+iczCdu7sBV+UuJ+Xv33pGuJxPeuAg@mail.gmail.com>
 <201212250336.36874.lindner_marek@yahoo.de>
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
In-Reply-To: <201212250336.36874.lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

On Tuesday, December 25, 2012 03:36:36 Marek Lindner wrote:
> > >> > empty, this assumption is wrong:
> > >> Why isn't this patch part of Linux 3.7? It seems to be a bugfix and it
> > >> was sent early enough?
> > > 
> > > The patch received a reply mere 2 hours after it was sent. Again,
> > > please read all mails before making noise.
> > 
> > Ok, leaving this problem unsolved is the correct way to handle it?
> > Nobody is allowed to say anything?
> 
> No, of course you are allowed "to say" something. I was simply pointing you
> to the explanation why the patch wasn't merged yet.

Let me add here: Feel free to do the required cleanup work and re-submit the 
patch. Nobody stops you from doing that as well.  :-)

Cheers,
Marek
