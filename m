From: Sami Farin <safari-kernel@safari.iki.fi>
Subject: Re: e1000e fails to find IRQ
Date: Mon, 3 Mar 2008 21:03:40 +0200
Message-ID: <20080303190339.wbilb6qaknwvj4sk@m.safari.iki.fi>
References: <20080303124443.52gfbwwmahxf7wmk@m.safari.iki.fi> <47CC3DF7.20907@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn1.fre.skanova.net ([81.228.11.168]:36969 "EHLO
	pne-smtpout4-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761620AbYCCTDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 14:03:42 -0500
Received: from safari.iki.fi (80.223.84.180) by pne-smtpout4-sn1.fre.skanova.net (7.3.129)
        id 47A7970A0017DE65 for netdev@vger.kernel.org; Mon, 3 Mar 2008 20:03:41 +0100
Content-Disposition: inline
In-Reply-To: <47CC3DF7.20907@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2008 at 10:05:43 -0800, Kok, Auke wrote:
> Sami Farin wrote:
..
> > I have Intel DQ965GF mobo, version CO96510J.86A.6002.2007.1125.2356,
> > Linux 2.6.24.3.
> 
> a bit unclear what kernel version you are actually using here... the device that
> you have (ich8 onboard lan) is NOT supported in 2.6.24.x by e1000e - you'll have

OK, that was not very clear from "PCI interrupt disabled" message.

> to use the e1000 driver until 2.6.25 ships.
> 
> what kernel version are you using here?

2.6.24.3.

I thought I could try e1000e for fun, because e1000 module said:
  This device (id 8086:104a) will no longer be supported by this driver
  in the future, please use the "e1000e" driver
:)

-- 
Do what you love because life is too short for anything else.

