From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 7/8] NetXen: Fix for PPC machines.
Date: Tue, 26 Dec 2006 16:49:25 -0500
Message-ID: <459198E5.7080804@garzik.org>
References: <200612181353.kBIDrx7D012229@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brazilnut@us.ibm.com,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41661 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932822AbWLZVt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:49:27 -0500
To: "Amit S. Kale" <amitkale@netxen.com>
In-Reply-To: <200612181353.kBIDrx7D012229@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amit S. Kale wrote:
> Signed-off-by: Amit S. Kale <amitkale@netxen.com> 
>  
>  netxen_nic.h      |    2 +-
>  netxen_nic_init.c |   12 ++++++------
>  netxen_nic_main.c |    4 ++--

applied 7-8.

your patch format is also broken:  please read 
Documentation/SubmittingPatches, in particular:

> 12) The canonical patch format
[...]
> The canonical patch message body contains the following:
[...]
>   - A marker line containing simply "---".

The diffstat output should come after the marker line, to avoid getting 
pasted into the kernel changelog.

	Jeff


