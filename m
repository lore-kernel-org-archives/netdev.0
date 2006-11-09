From: chunkeey@web.de
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Thu, 9 Nov 2006 18:38:33 +0100
Message-ID: <200611091838.33252.chunkeey@web.de>
References: <200610031457.33215.chunkeey@web.de> <43e72e890611031041x1e07306cwbb16bcfa0fd782a7@mail.gmail.com> <20061108003934.GB2964@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:57240 "EHLO
	fmmailgate03.web.de") by vger.kernel.org with ESMTP id S966046AbWKIRhb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 12:37:31 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061108003934.GB2964@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 8. November 2006 01:39 schrieben Sie:
> On Fri, Nov 03, 2006 at 01:41:46PM -0500, Luis R. Rodriguez wrote:
> > On 11/3/06, chunkeey@web.de <chunkeey@web.de> wrote:
> > >yes, especially mgt_commit_list caused alot headaches, until I removed
> > >DOT11_OID_PSM from the cache list.
> > >Now, I can "hammer" it with ping -f for hours.
> >
> > nice, perhaps that's been the culprit all along... going to dig to see
> > if I find a fullmac prism card. Will like to get this merged in.
>
> Any resolution on this?

no replies.
Seems like it works for just fine for everybody. ;)

Christian
