From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: netfilter: ipset: fix incorret comparison in
 hash_netnet4_data_equal()
Date: Sat, 7 Dec 2013 23:34:36 +0100
Message-ID: <20131207223436.GA3927@localhost>
References: <20131114154101.GA22625@redhat.com>
 <20131125214511.GA10043@localhost>
 <19530135.WLZhKuFLxq@gentoovm>
 <alpine.DEB.2.10.1312072052580.11375@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>,
	Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1312072052580.11375@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 07, 2013 at 08:53:52PM +0100, Jozsef Kadlecsik wrote:
> On Sat, 7 Dec 2013, Oliver wrote:
> 
> > On Monday 25 November 2013 22:45:11 Pablo Neira Ayuso wrote:
> > > On Thu, Nov 14, 2013 at 10:41:01AM -0500, Dave Jones wrote:
> > > > Both sides of the comparison are the same, looks like a cut-and-paste
> > > > error.
> > 
> > Just a typo unfortunately.
> > 
> > The change should definitely make its way into mainline before 3.13 gets 
> > released - is it on track to be pulled into davem's net tree or should I 
> > get that sorted out myself?
> 
> I'm going to submit the patch to Pablo at the beginning of next week, so 
> it'll follow the normal track.

JFYI, I applied this already:

http://www.spinics.net/lists/netfilter-devel/msg29031.html

If unsure, please check my tree:

http://git.kernel.org/cgit/linux/kernel/git/pablo/nf.git/
