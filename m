From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 1/1] AF_UNIX Datagram getpeersec (minor fix)
Date: Thu, 29 Jun 2006 12:28:00 -0700 (PDT)
Message-ID: <20060629.122800.108743929.davem@davemloft.net>
References: <20060628053432.GA27226@jiayuguan.watson.ibm.com>
	<Pine.LNX.4.64.0606281000150.12544@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cxzhang@watson.ibm.com, netdev@vger.kernel.org, jmorris@redhat.com,
	chrisw@osdl.org, herbert@gondor.apana.org.au, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, akpm@osdl.org, latten@austin.ibm.com,
	sergeh@us.ibm.com, gcwilson@us.ibm.com, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:39844
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932303AbWF2T2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 15:28:03 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0606281000150.12544@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Wed, 28 Jun 2006 10:00:48 -0400 (EDT)

> On Wed, 28 Jun 2006, Catherine Zhang wrote:
> 
> > Hi,
> > 
> > Minor fix (un-export selinux_get_sock_sid()).
> 
> Thanks, looks ok to me.
> 
> Acked-by: James Morris <jmorris@namei.org>

Applied, thanks a lot.
