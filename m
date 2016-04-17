From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: FlameGraph of mlx4 early drop with order-0 pages
Date: Sun, 17 Apr 2016 18:52:43 +0100
Message-ID: <20160417175243.GA15167@techsingularity.net>
References: <20160415214034.6ffae9ee@redhat.com>
 <20160417132357.GB11792@techsingularity.net>
 <20160417192432.70c893fc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: linux-mm <linux-mm@kvack.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Brenden Blanco <bblanco@plumgrid.com>, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com, ecree@solarflare.com,
	john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20160417192432.70c893fc@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 17, 2016 at 07:24:32PM +0200, Jesper Dangaard Brouer wrote:
> On Sun, 17 Apr 2016 14:23:57 +0100
> Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > > Signing off, heading for the plane soon... see you at MM-summit!  
> > 
> > Indeed and we'll slap some sort of plan together. If there is a slot free,
> > we might spend 15-30 minutes on it. Failing that, we'll grab a table
> > somewhere. We'll see how far we can get before considering a page-recycle
> > layer that preserves cache coherent state.
> 
> We have a plenum slot tomorrow between 16:00-16:30, called "Generic
> Page Pool Facility".
> 

Yeah. We can use part of that if you like to discuss page allocator
concerns. I didn't want to accidentally hijack a session if it was going
to focus on an API for storing cache coherent pages. My focus will still
be on improving the allocator itself and what would and would not be
acceptable there.

> I'm at the Marriott now. I'm wearing my Red Hat/fedora, so I should be
> easy to spot... ;-)
> 

I'll keep an eye out!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
