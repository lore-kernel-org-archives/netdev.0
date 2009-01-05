From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -net-next 1/4] firmware: convert e100 driver to
 request_firmware()
Date: Sun, 04 Jan 2009 21:34:02 -0800 (PST)
Message-ID: <20090104.213402.12464178.davem@davemloft.net>
References: <9929d2390812301433pae01ea4g5bfdef6d4d4c7a9c@mail.gmail.com>
	<20090104.160611.252248503.davem@davemloft.net>
	<9929d2390901041820h4cf51e2h3612108c516b6869@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jaswinder@infradead.org, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <9929d2390901041820h4cf51e2h3612108c516b6869@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Date: Sun, 4 Jan 2009 18:20:24 -0800

> On Sun, Jan 4, 2009 at 4:06 PM, David Miller <davem@davemloft.net> wrote:
> > From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
> > Date: Tue, 30 Dec 2008 14:33:36 -0800
> >
> >> Please hold off on committing, until we have had ample time to do some
> >> regression testing.  While this patch may have been in linux-next,
> >> this is the first we have seen of it.
> >>
> >> I am concerned that IPMI traffic will be adversely affected by this patch.
> >
> > Status please?
> > --
> 
> The only testing left to do is to make sure that ICH devices still
> work and to make sure the IPMI traffic is not affected by this patch.
> All other testing looks good.  I am sorry that I have been slow to
> give status, the holiday's have put a strain on available resources.

Ok, thanks for the update.
