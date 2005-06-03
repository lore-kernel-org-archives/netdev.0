From: Kosta Todorovic <kostodo@gmail.com>
Subject: Re: Network card driver problem (znb.o/tulip)
Date: Fri, 3 Jun 2005 09:58:44 +0400
Message-ID: <efe3b0060506022258519aa826@mail.gmail.com>
References: <efe3b00605031021513b7268d1@mail.gmail.com>
	 <efe3b00605051901022854653a@mail.gmail.com>
	 <428CC958.1080909@candelatech.com>
	 <efe3b0060505192225f3cf36e@mail.gmail.com>
	 <428E0B3B.1090507@candelatech.com>
	 <efe3b00605060222452675d8fc@mail.gmail.com>
	 <429FF071.8040707@candelatech.com>
Reply-To: Kosta Todorovic <kostodo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: jgarzik@pobox.com, tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <429FF071.8040707@candelatech.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

So intel gigE nics use standard tulip linux drivers that come shipped
with a vanilla kernel?

On 6/3/05, Ben Greear <greearb@candelatech.com> wrote:
> Kosta Todorovic wrote:
> > I'm not too concerned with backward compatibility. I see silicom-usa
> > provide both a Broadcom and Intel based chipsets.
> >
> > Is there any reason in particular that you reccomended Broadcom? And
> > can standard kernel drivers be used for these cards? I've had bad
> > expirience with custom manufactorer drivers once they discontinue
> > development and support for their card.
> 
> The BCM NICs will work in a normal 32-bit PCI bus..the 4-port Intels will
> not.  If you have 64-bit PCI-X, then I'd get Intel..but that's just because
> I've used them longer...I have no reason to believe the BCM is inferior at
> this time.
> 
> > How reliable is Silicom-usa?
> >
> > As a management decision, who would you purchase 10 quad port cards
> > from and which kinds of cards would u get?
> 
> Heh, I've already purchased more than 10 from silicom, and have shipped
> them all over the world.  So far...no complaints!  But, if you don't
> need the BCM, you can get good ole Intel quad GigE NICs from www.newegg.com
> and a million other places.
> 
> Ben
> 
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 
>
