From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [E1000-devel] [net-next v4 7/8] i40e: sysfs and debugfs
 interfaces
Date: Thu, 5 Sep 2013 08:21:10 -0700
Message-ID: <20130905082110.68772c69@nehalam.linuxnetplumber.net>
References: <1378336629-24224-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1378336629-24224-8-git-send-email-jeffrey.t.kirsher@intel.com>
	<20130904173759.7c2eec52@nehalam.linuxnetplumber.net>
	<FC41C24E35F18A40888AACA1A36F3E416C61CF23@FMSMSX102.amr.corp.intel.com>
	<CAOaVG17stH4K=MOfB0-OfqerVOmXpGQtERD7kgCF97AOtpn18A@mail.gmail.com>
	<8761uf5xt0.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Nelson\, Shannon" <shannon.nelson@intel.com>,
	"Kirsher\, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"e1000-devel\@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg\, Jesse" <jesse.brandeburg@intel.com>,
	"gospo\@redhat.com" <gospo@redhat.com>,
	"davem\@davemloft.net" <davem@davemloft.net>,
	"sassmann\@redhat.com" <sassmann@redhat.com>
To: =?ISO-8859-1?B?Qmr4cm4=?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:45925 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753931Ab3IEPVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 11:21:14 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so1928314pbb.41
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 08:21:14 -0700 (PDT)
In-Reply-To: <8761uf5xt0.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Has anyone else noticed how big the drivers are getting.

Intel
	e100	2275
	e1000	11971
	e1000e	17502
	igb	15720
	ixgbe	22451
	i40e	22603



	
