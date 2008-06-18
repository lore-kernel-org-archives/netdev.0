From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [PATCH] ibm_emac: Remove the ibm_emac driver
Date: Tue, 17 Jun 2008 18:57:12 -0700
Message-ID: <20080618015712.GC30602@gate.ebshome.net>
References: <20080617193523.028d4cc2@zod.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.ebshome.net ([208.106.21.240]:37648 "EHLO gate.ebshome.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759004AbYFRCDx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 22:03:53 -0400
Content-Disposition: inline
In-Reply-To: <20080617193523.028d4cc2@zod.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 07:35:23PM -0400, Josh Boyer wrote:
> The arch/ppc sub-tree has been removed in the powerpc git tree.  The old
> ibm_emac driver is no longer used by anything as a result of this.  This
> removes it, leaving the ibm_newemac driver as the proper driver to use for
> PowerPC boards with the EMAC hardware.
> 
> Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>

Acked-by: Eugene Surovegin <ebs@ebshome.net>


