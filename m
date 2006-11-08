From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Tue, 7 Nov 2006 19:39:40 -0500
Message-ID: <20061108003934.GB2964@tuxdriver.com>
References: <200610031457.33215.chunkeey@web.de> <1162565362.2863.1.camel@localhost.localdomain> <43e72e890611030806x14745b17q4916b785a7fb5f8e@mail.gmail.com> <200611031912.35525.chunkeey@web.de> <43e72e890611031041x1e07306cwbb16bcfa0fd782a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "chunkeey@web.de" <chunkeey@web.de>, netdev@vger.kernel.org,
	Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:47116 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1753501AbWKHAyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 19:54:17 -0500
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Content-Disposition: inline
In-Reply-To: <43e72e890611031041x1e07306cwbb16bcfa0fd782a7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 03, 2006 at 01:41:46PM -0500, Luis R. Rodriguez wrote:
> On 11/3/06, chunkeey@web.de <chunkeey@web.de> wrote:

> >yes, especially mgt_commit_list caused alot headaches, until I removed
> >DOT11_OID_PSM from the cache list.
> >Now, I can "hammer" it with ping -f for hours.
> 
> nice, perhaps that's been the culprit all along... going to dig to see
> if I find a fullmac prism card. Will like to get this merged in.

Any resolution on this?

-- 
John W. Linville
linville@tuxdriver.com
