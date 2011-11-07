From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-ext PATCH] ixgbe: Fix compile for kernel without
 CONFIG_PCI_IOV defined
Date: Mon, 7 Nov 2011 10:25:32 -0800
Message-ID: <43F901BD926A4E43B106BF17856F075501A1CCA520@orsmsx508.amr.corp.intel.com>
References: <20111107174417.8638.87569.stgit@gitlad.jf.intel.com>
 <20111107.132340.124929090969671336.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:65033 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932491Ab1KGSZd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 13:25:33 -0500
In-Reply-To: <20111107.132340.124929090969671336.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, November 07, 2011 10:24 AM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org
> Subject: Re: [net-ext PATCH] ixgbe: Fix compile for kernel without
> CONFIG_PCI_IOV defined
> 
> From: Greg Rose <gregory.v.rose@intel.com>
> Date: Mon, 07 Nov 2011 09:44:17 -0800
> 
> > Fix compiler errors and warnings with CONFIG_PCI_IOV defined and not
> > defined.
> >
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> 
> It's "net-next" not "net-ext" :-)
> 
> Applied, thanks.

Ugh... I'm really stepping in it deep.

Thanks Dave,

- Greg
