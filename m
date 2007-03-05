From: Mithlesh Thukral <mithlesh@linsyssoft.com>
Subject: Re: [PATCH 3/3] NetXen: Make driver use multi PCI functions
Date: Mon, 5 Mar 2007 18:27:57 +0530
Message-ID: <200703051827.57474.mithlesh@linsyssoft.com>
References: <200702281319.l1SDJ2FV004424@dut39.unminc.com> <45E8C9CC.7030005@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>,
	netdev@vger.kernel.org, netxenproj@linsyssoft.com, rob@netxen.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:43561 "EHLO
	svr68.ehostpros.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933429AbXCENC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 08:02:58 -0500
In-Reply-To: <45E8C9CC.7030005@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 03 March 2007 06:35, Jeff Garzik wrote:
> Linsys Contractor Mithlesh Thukral wrote:
> > NetXen: Make driver use multi PCI functions.
> >
> > Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> >
> > ---
> >
> >  netxen_nic.h          |  126 +++++-------
> >  netxen_nic_ethtool.c  |   80 +++----
> >  netxen_nic_hdr.h      |    8
> >  netxen_nic_hw.c       |  213 +++++++++++++++-----
> >  netxen_nic_hw.h       |   18 -
> >  netxen_nic_init.c     |  115 +++-------
> >  netxen_nic_isr.c      |   80 +++----
> >  netxen_nic_main.c     |  523
> > +++++++++++++++++++++++++------------------------- netxen_nic_niu.c     
> > |   27 +-
> >  netxen_nic_phan_reg.h |  125 -----------
> >  10 files changed, 631 insertions(+), 684 deletions(-)
>
> all three patches in this patchset contained nothing but one-line
> summaries of the changes included in them, and are overall very poorly
> and vaguely described.
>
> This patch is far too big, with far too little description and
> justification to go along with it.
>
> If you are not going to make the effort to write a paragraph or two
> describing such huge changes, then I'm not going to make the effort to
> review and apply it.  NAK.
My apologies for insufficient explanation of the patch. I have resend this 
patch some time ago. 

Regards,
Mithlesh Thukral
