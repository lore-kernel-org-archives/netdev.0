From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: udev can't name PS3's network devices correctly
Date: Sun, 27 Apr 2008 20:28:13 +0200
Message-ID: <1209320893.3356.3.camel@linux.site>
References: <ftdb3v$tls$1@ger.gmane.org>
	 <20080407143805.GA9492@bongo.bofh.it>
	 <1208167737.31695.32.camel@pmac.infradead.org>
	 <1208171478.31695.58.camel@pmac.infradead.org>
	 <3ae72650804140455l4bb2afc2i4c54e58f3be1f931@mail.gmail.com>
	 <1209317870.25560.66.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marco d'Itri <md@linux.it>, Harald Hoyer <harald@redhat.com>,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <1209317870.25560.66.camel@pmac.infradead.org>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2008-04-27 at 18:37 +0100, David Woodhouse wrote:
> On Mon, 2008-04-14 at 13:55 +0200, Kay Sievers wrote:
> > 
> > >  +# match dev_id
> > >  +ENV{MATCHDEVID}="$attr{dev_id}"
> > >  +
> > 
> > Sure, looks good. Let me know when the kernel part gets merged, and I
> > will apply that.
> 
> http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=9d29672c64505f2d7f707701b829715705308a69

http://git.kernel.org/?p=linux/hotplug/udev.git;a=commitdiff;h=8b6e9f287d4ba774a12c023c2ef8fc78def29df8

I have a link for you too. :)

Thanks,
Kay

