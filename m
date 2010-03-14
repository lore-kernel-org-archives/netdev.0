From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [PATCH 00/13] TProxy IPv6 support 2nd round
Date: Sun, 14 Mar 2010 10:00:30 +0100
Message-ID: <1268557230.16066.20.camel@bzorp.balabit>
References: <1253548300.12519.20.camel@bzorp.balabit>
	 <20091025101612.GS29852@prithivi.gnumonks.org>
	 <1256547636.11361.18.camel@bzorp.balabit>  <4B94C57A.5010605@treenet.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Amos Jeffries <squid3@treenet.co.nz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B94C57A.5010605@treenet.co.nz>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-03-08 at 22:38 +1300, Amos Jeffries wrote:
> Balazs Scheidler wrote:
> > On Sun, 2009-10-25 at 11:16 +0100, Harald Welte wrote:
> >> Dear Balazs,
> >>
> >> as you might have read from other mails (and by the long period of silence),
> >> Patrick McHardy is currently unavailable to perform his usual maintainer
> >> role.
> >>
> >> I personally am too much out of touch with recent developments in
> >> netfitler-land to be able to confidently review your patches...  
> >>
> >> So unless somebody else from the team (Jozsef?, Pablo?) feels confident in
> >> ACKing your patchset, I will have to ask for your patience until Patrick is
> >> back and can do it by himself.
> > 
> > Thanks for letting me know, hopefully Patrick gets better soon. I've
> > planned another round of the TProxy patches as I got some comments at
> > the previous round I'm yet to address.
> > 
> > So no need to hurry.
> > 
> 
> Just bumping this topic up again.
> 
> What is the current status of these patches?
> 
> Our release which might make use of them goes into production sites in a 
> few weeks and I'm starting to see a little more interest in them from 
> our users.

Well, no news ever since. I was backlogged with other stuff, so didn't
push these too much. All I got was two comments to be fixed:

1) indentation should use tabs instead of spaces

2) the IPv6 address detection should be changed to use a function
instead of relying on the first IPv6 address on the interface.

Hopefully I can give this some care in the coming weeks.

-- 
Bazsi


