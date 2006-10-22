From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 kernel bug in 2.6.18-mm3 and 2.6.19-rc2-mm2
Date: Sat, 21 Oct 2006 22:47:52 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FC5D@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <20061021234107.GA12918@gamma.logic.tuwien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:53520 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1423014AbWJVFsH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Oct 2006 01:48:07 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20061021234107.GA12918@gamma.logic.tuwien.ac.at>
To: "Norbert Preining" <preining@logic.at>,
	"Andrew Morton" <akpm@osdl.org>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Norbert Preining wrote:
> On Sam, 21 Okt 2006, Andrew Morton wrote:
> > Can you test 2.6.19-rc2 plus the below?
> 
> 2.6.19-rc2	works
> 2.6.19-rc2+patch does not work
> 
> So it is this patch.
> 
It doesn't make any sense.  This patch is totally benign and
cannot cause the "No firmware running" and lockup that you
reported.  Can you please double-check?

