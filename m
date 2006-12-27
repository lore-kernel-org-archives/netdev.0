From: Amit Kale <amitkale@netxen.com>
Subject: Re: [PATCH 7/8] NetXen: Fix for PPC machines.
Date: Wed, 27 Dec 2006 11:16:10 +0530
Message-ID: <200612271116.11036.amitkale@netxen.com>
References: <200612181353.kBIDrx7D012229@dut39.unminc.com> <459198E5.7080804@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brazilnut@us.ibm.com,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:3484 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932919AbWL0FqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 00:46:16 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <459198E5.7080804@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks a lot for applying.
We'll definitely take care of the patch format  problems you've pointed out.
-Amit

On Wednesday 27 December 2006 03:19, Jeff Garzik wrote:
> Amit S. Kale wrote:
> > Signed-off-by: Amit S. Kale <amitkale@netxen.com>
> >
> >  netxen_nic.h      |    2 +-
> >  netxen_nic_init.c |   12 ++++++------
> >  netxen_nic_main.c |    4 ++--
>
> applied 7-8.
>
> your patch format is also broken:  please read
>
> Documentation/SubmittingPatches, in particular:
> > 12) The canonical patch format
>
> [...]
>
> > The canonical patch message body contains the following:
>
> [...]
>
> >   - A marker line containing simply "---".
>
> The diffstat output should come after the marker line, to avoid getting
> pasted into the kernel changelog.
>
> 	Jeff
