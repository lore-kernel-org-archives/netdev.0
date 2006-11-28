From: "Felix Marti" <felix@chelsio.com>
Subject: Re: [PATCH 1/2] chelsio: T200 support
Date: Tue, 28 Nov 2006 10:03:31 -0800
Message-ID: <8A71B368A89016469F72CD08050AD334DA4F5C@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:55159 "EHLO
	stargate.chelsio.com") by vger.kernel.org with ESMTP
	id S936002AbWK1SDr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 13:03:47 -0500
Content-class: urn:content-classes:message
To: <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew:
> On Tue, 28 Nov 2006 00:17:38 +0100
> Francois Romieu <romieu@fr.zoreil.com> wrote:
>
> > Stephen Hemminger <shemminger@osdl.org> :
> > > This patch is experimental, it applies after the earlier 6 chelsio
cleanup
> > > patches. Tested on a pair of T210 board's.
> > 
> > The whole serie is stored as branch 'chelsio' at:
> >
git://electric-eye.fr.zoreil.com/home/romieu/linux/linux-2.6-out/.git
chelsio
>
> I think you meant
> git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git#chelsio
>
> > I have hand-edited a few patches to convert some spaces/tabs.
>
> I'll try adding this to -mm.
>
> I hope someone knows what's happening with this driver, because I've
> seriously lost the plot.

Most customers have been downloading the T2xx driver from our website in
order to take advantage of the TOE capability of the T2xx hardware.
However, there is value in updating the in-kernel driver (which supports
N110 and N210 only) to support the T2xx products in NIC mode. I will
test the patches this week and get back to the mailing list if there are
any issues.

Regards,
felix

