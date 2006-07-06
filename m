From: Denis Vlasenko <vda.linux@googlemail.com>
Subject: Re: ACX100 (softmac-based) driver ready to merge, but is it legal?
Date: Thu, 6 Jul 2006 19:29:49 +0200
Message-ID: <200607061929.49103.vda.linux@gmail.com>
References: <20060604135011.decdc7c9.akpm@osdl.org> <1149524691.30554.23.camel@localhost.localdomain> <20060629142643.GA24463@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:1982 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1030318AbWGFR34 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2006 13:29:56 -0400
Received: by ug-out-1314.google.com with SMTP id a2so2762968ugf
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2006 10:29:55 -0700 (PDT)
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060629142643.GA24463@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 29 June 2006 16:26, John W. Linville wrote:
> I apologize for the long copy list. =A0I have tried to include all
> known interested parties.
>=20
> This is a follow-up to a thread started by Andrew a few weeks ago
> about what should be merged for 2.6.18. =A0One of the topics he cited
> was the ACX100 driver which he has carried in -mm for quite some time=
=2E
> I have a slightly different (softmac based) version of that driver
> in wireless-2.6 which I think is worth merging now.
>=20
> In the aforementioned thread, some questions were raised about the
> legality of the ACX100 driver (i.e. tiacx) code base, but no one
> had any specific points other than that it is not 100% "clean room"
> derived. =A0Others point-out that this is not strictly a requirement.
> The matter dropped without a strong defense from the tiacx team.
>
> I hereby invite the tiacx team to defend their work by making public,
> affirmative statements indicating a) how they produced their code; an=
d,
> b) that they have the legal right to license it as part of the Linux
> kernel under the GPL. =A0As an incentive to this, I have already made
> the necessary preparations for this driver to be merged immediately.

About the part of the acx code which was done by me:
I was working upon the already existing acx driver.

I do not know how it was developed before I started to play with it,
but I certainly never worked for TI and did not receive any code
or documents from TI (I was asking for the documentation,
but there was no answer).

I realize that this info is not enough to determine whether tiacx
driver is "clean" legalese-wise.
--
vda
