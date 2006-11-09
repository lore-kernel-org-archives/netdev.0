From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Thu, 9 Nov 2006 18:16:04 -0500
Message-ID: <43e72e890611091516q7bc8f1f0gc0619edda2c389d5@mail.gmail.com>
References: <200610031457.33215.chunkeey@web.de>
	 <43e72e890611031041x1e07306cwbb16bcfa0fd782a7@mail.gmail.com>
	 <20061108003934.GB2964@tuxdriver.com>
	 <200611091838.33252.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:10064 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1424250AbWKIXQI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 18:16:08 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1185187nfa
        for <netdev@vger.kernel.org>; Thu, 09 Nov 2006 15:16:05 -0800 (PST)
To: "chunkeey@web.de" <chunkeey@web.de>
In-Reply-To: <200611091838.33252.chunkeey@web.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/9/06, chunkeey@web.de <chunkeey@web.de> wrote:
> Am Mittwoch, 8. November 2006 01:39 schrieben Sie:
> > On Fri, Nov 03, 2006 at 01:41:46PM -0500, Luis R. Rodriguez wrote:
> > > On 11/3/06, chunkeey@web.de <chunkeey@web.de> wrote:
> > > >yes, especially mgt_commit_list caused alot headaches, until I removed
> > > >DOT11_OID_PSM from the cache list.
> > > >Now, I can "hammer" it with ping -f for hours.
> > >
> > > nice, perhaps that's been the culprit all along... going to dig to see
> > > if I find a fullmac prism card. Will like to get this merged in.
> >
> > Any resolution on this?
>
> no replies.
> Seems like it works for just fine for everybody. ;)

I found a card, I just need time to test it. Dan didn't you say you
ran into issues with the patch on your card?

  Luis
