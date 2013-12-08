From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: netfilter: ipset: fix incorret comparison in
 hash_netnet4_data_equal()
Date: Sun, 8 Dec 2013 10:31:29 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1312081030450.12477@blackhole.kfki.hu>
References: <20131114154101.GA22625@redhat.com> <20131125214511.GA10043@localhost> <19530135.WLZhKuFLxq@gentoovm> <alpine.DEB.2.10.1312072052580.11375@blackhole.kfki.hu> <20131207223436.GA3927@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Oliver <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>,
	Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20131207223436.GA3927@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 7 Dec 2013, Pablo Neira Ayuso wrote:

> On Sat, Dec 07, 2013 at 08:53:52PM +0100, Jozsef Kadlecsik wrote:
> > On Sat, 7 Dec 2013, Oliver wrote:
> > 
> > > On Monday 25 November 2013 22:45:11 Pablo Neira Ayuso wrote:
> > > > On Thu, Nov 14, 2013 at 10:41:01AM -0500, Dave Jones wrote:
> > > > > Both sides of the comparison are the same, looks like a cut-and-paste
> > > > > error.
> > > 
> > > Just a typo unfortunately.
> > > 
> > > The change should definitely make its way into mainline before 3.13 gets 
> > > released - is it on track to be pulled into davem's net tree or should I 
> > > get that sorted out myself?
> > 
> > I'm going to submit the patch to Pablo at the beginning of next week, so 
> > it'll follow the normal track.
> 
> JFYI, I applied this already:
> 
> http://www.spinics.net/lists/netfilter-devel/msg29031.html
> 
> If unsure, please check my tree:
> 
> http://git.kernel.org/cgit/linux/kernel/git/pablo/nf.git/

Great, thanks indeed!

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
