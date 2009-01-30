From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: [ SPAM ] ixgbe in kernel driver question
Date: Fri, 30 Jan 2009 17:22:19 +0100
Message-ID: <4983293B.1020308@itcare.pl>
References: <49832695.7020802@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:36336 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128AbZA3QWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 11:22:23 -0500
Received: from unknown (HELO [192.168.1.10]) (itcare_pstaszewski@[83.4.198.230])
          (envelope-sender <pstaszewski@itcare.pl>)
          by smtp.iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 30 Jan 2009 16:22:20 -0000
In-Reply-To: <49832695.7020802@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And i use kernel 2.6.28.2
my lspci shows my intel card as:
=2E..
01:00.0 Ethernet controller: Intel Corporation Device 10dd (rev 01)
=2E..

My installed card in this machine is:
Intel=C2=AE 82598EB 10 Gigabit Ethernet Controller with CX4 interface




Pawe=C5=82 Staszewski pisze:
> I have question about ixgbe in kernel driver compared to ixgbe driver=
=20
> that is on sourceforge
> http://sourceforge.net/project/showfiles.php?group_id=3D42302&package=
_id=3D247088=20
>
>
> What is difference between this drivers ?
> and does driver in kernel 2.6.28.2
>
> ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 1.3.3=
0-k2
> ixgbe: Copyright (c) 1999-2007 Intel Corporation.
> ixgbe 0000:01:00.0: setting latency timer to 64
>
> is this driver closest version to :
> http://sourceforge.net/project/shownotes.php?release_id=3D611160&grou=
p_id=3D42302=20
>
>
> on e1000.sourcerofge ??
>
>
> Or this driver have different versions releases ? with different=20
> changes that are made in kernel tree network drivers
>
> because i have problems with in kernel ixgbe drivers that i can=20
> compare to some fixes that are made in:
> 1.3.31.5 driver on e1000 site
> http://sourceforge.net/project/shownotes.php?release_id=3D611160&grou=
p_id=3D42302=20
>
>
> i think about this fix:
>
> cpu utilization fix for MSI and legacy interrupts in kernels with=20
> CONFIG_NETDEVICES_MULTIQUEUE enabled but default (non multiqueue)=20
> aware qdisc loaded
>
>
>
>
>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
>
>

