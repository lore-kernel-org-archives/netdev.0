From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac
	cards
Date: Fri, 10 Nov 2006 09:42:20 -0500
Message-ID: <1163169740.2662.6.camel@localhost.localdomain>
References: <200610031457.33215.chunkeey@web.de>
	 <43e72e890611031041x1e07306cwbb16bcfa0fd782a7@mail.gmail.com>
	 <20061108003934.GB2964@tuxdriver.com> <200611091838.33252.chunkeey@web.de>
	 <43e72e890611091516q7bc8f1f0gc0619edda2c389d5@mail.gmail.com>
	 <43e72e890611091516r3362945dm715276f0841ad366@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "chunkeey@web.de" <chunkeey@web.de>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34720 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1424326AbWKJOks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 09:40:48 -0500
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890611091516r3362945dm715276f0841ad366@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-09 at 18:16 -0500, Luis R. Rodriguez wrote:
> On 11/9/06, Luis R. Rodriguez <mcgrof@gmail.com> wrote:
> > On 11/9/06, chunkeey@web.de <chunkeey@web.de> wrote:
> > > Am Mittwoch, 8. November 2006 01:39 schrieben Sie:
> > > > On Fri, Nov 03, 2006 at 01:41:46PM -0500, Luis R. Rodriguez wrote:
> > > > > On 11/3/06, chunkeey@web.de <chunkeey@web.de> wrote:
> > > > > >yes, especially mgt_commit_list caused alot headaches, until I removed
> > > > > >DOT11_OID_PSM from the cache list.
> > > > > >Now, I can "hammer" it with ping -f for hours.
> > > > >
> > > > > nice, perhaps that's been the culprit all along... going to dig to see
> > > > > if I find a fullmac prism card. Will like to get this merged in.
> > > >
> > > > Any resolution on this?
> > >
> > > no replies.
> > > Seems like it works for just fine for everybody. ;)
> >
> > I found a card, I just need time to test it. Dan didn't you say you
> > ran into issues with the patch on your card?

No, more that my card doesn't successfully associate at all even
_without_ the patch on unencrypted or WEP APs; I just can't test it,
since my card seems to be broken...

Dan

> >   Luis
> 
> CC'ing Dan to make sure he gets it ;)

