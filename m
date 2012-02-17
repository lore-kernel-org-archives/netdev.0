From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Regression in skge that started around acb42a3 (so past
 v3.3-rc1)
Date: Fri, 17 Feb 2012 07:53:48 -0800
Message-ID: <20120217075348.171e3476@nehalam.linuxnetplumber.net>
References: <20120130155816.GA1400@phenom.dumpdata.com>
	<20120130083843.160ffe5e@nehalam.linuxnetplumber.net>
	<20120130175738.GA4002@phenom.dumpdata.com>
	<20120130.130259.1190745234966440677.davem@davemloft.net>
	<20120130182230.GA4122@phenom.dumpdata.com>
	<20120217141005.GA27808@phenom.dumpdata.com>
	<20120217074511.61efe78c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120217074511.61efe78c@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Feb 2012 07:45:11 -0800
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Fri, 17 Feb 2012 09:10:05 -0500
> Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> wrote:
> 
> > On Mon, Jan 30, 2012 at 01:22:30PM -0500, Konrad Rzeszutek Wilk wrote:
> > > On Mon, Jan 30, 2012 at 01:02:59PM -0500, David Miller wrote:
> > > > From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > > > Date: Mon, 30 Jan 2012 12:57:38 -0500
> > > > 
> > > > > Ah, so you are saying that the problem above is already fixed in 3.3-rc1.
> > > > 
> > > > No he's not saying that, he says somewhere we probably need a fix
> > > > "like" the commit he mentioned.
> > > > 
> > > > He did not say that commit fixes this bug.
> > > 
> > > Ayee. Sounds you guys have an idea about this bug then. If you want me to run
> > > a test-patch I can certainly do so. Thanks!
> > 

Actually, I was confused, that was another skge change.
The checksum issue still exists and it is not a driver problem.
