From: "Matti Linnanvuori" <mattilinn@gmail.com>
Subject: Re: [patch v1.2.34] WAN: merge driver retina
Date: Mon, 29 Sep 2008 14:56:49 +0300
Message-ID: <ca0148c30809290456m5e832092l9c85a666f9bef204@mail.gmail.com>
References: <ca0148c30807032339o4182fbadq370f709a28861053@mail.gmail.com>
	 <489A96B2.4030903@pobox.com>
	 <ca0148c30808072334w5d2d8216s37152621b4aa8ebf@mail.gmail.com>
	 <ca0148c30808120246w5c2eca09u3bfa08e3ea40cfe4@mail.gmail.com>
	 <48CC57EB.9010500@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:31870 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751968AbYI2L4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 07:56:49 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2066588wfd.4
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2008 04:56:49 -0700 (PDT)
In-Reply-To: <48CC57EB.9010500@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/9/14 Jeff Garzik <jgarzik@pobox.com>:
> Changes look good, but do not apply to the 'retina' branch.  Also, the
> virt_to_bus/virt_to_phys stuff should be replaced with DMA mapping API
> usage.

I have replaced them.
