From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [2.6.18 backport] RTL8168 ethernet support in r8169
Date: Fri, 29 Sep 2006 09:00:21 +0200
Message-ID: <20060929070021.GB15396@electric-eye.fr.zoreil.com>
References: <451972B0.5020805@gentoo.org> <20060926191458.GB15039@electric-eye.fr.zoreil.com> <m264f7jso7.fsf@cerbere.dyndns.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50579 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1161451AbWI2HB4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 03:01:56 -0400
To: Samir Bellabes <sbellabes@mandriva.com>
Content-Disposition: inline
In-Reply-To: <m264f7jso7.fsf@cerbere.dyndns.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Samir Bellabes <sbellabes@mandriva.com> :
[...]
> > +	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8167), 0, 0, RTL_CFG_1 },
> >                                                            ^^^^^^^^^
> > Should be RTL_CFG_1.
> 
> You mean should be RTL_CFG_0 ?

Yes.

It was typos night.

-- 
Ueimor
