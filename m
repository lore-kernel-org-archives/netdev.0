From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [RFC 0/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Sat, 4 Aug 2007 10:02:35 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AABA15@nt-irva-0751.brcm.ad.broadcom.com>
References: <46B43D2D.2090800@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net, mchristi@redhat.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com,
	"Anil Veerabhadrappa" <anilgv@broadcom.com>,
	"Tal Moyal" <talm@broadcom.com>,
	"Robert Lusinsky" <lusinsky@broadcom.com>,
	"Uri Elzur" <uri@broadcom.com>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3638 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764048AbXHDRC6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2007 13:02:58 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46B43D2D.2090800@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> Michael Chan wrote:
> > [BNX2]: Add iSCSI support to BNX2 devices.
> > 
> > Modify bnx2 and add a cnic driver to support some offload functions
> > needed by iSCSI.
> > 
> > Add a new open-iscsi driver to support iSCSI offload on 
> bnx2 devices.
> > 
> > Signed-off-by: Anil Veerabhadrappa <anilgv@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > 
> > --
> > 
> > The complete patch is in:
> > 
> > 
> >
ftp://Net_sys_anon@ftp1.broadcom.com/0001-BNX2-Add-iSCSI-support-to-BNX2
-devices.patch
> 
> > I broke this into 2 patches and omitted the firmware blob in the
next 2
> > emails for review.

> patch #2/2 did not make it (to me personally nor to 
> http://marc.info/?l=linux-netdev)

Probably too big.  The complete patch is available from FTP above.
I'll try to break it up some more and resend later.







