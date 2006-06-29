From: Xiaolan Zhang <cxzhang@us.ibm.com>
Subject: Re: [Patch 1/1] AF_UNIX Datagram getpeersec (minor fix)
Date: Thu, 29 Jun 2006 15:29:17 -0400
Message-ID: <OF71DC2A94.2845B98C-ON8525719C.006AFEBB-8525719C.006B0CEA@us.ibm.com>
References: <20060629.122800.108743929.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: akpm@osdl.org, chrisw@osdl.org, cxzhang@watson.ibm.com,
	czhang.us@gmail.com, George Wilson <gcwilson@us.ibm.com>,
	herbert@gondor.apana.org.au, jmorris@redhat.com, jmorris@namei.org,
	latten@austin.ibm.com, netdev@vger.kernel.org, sds@tycho.nsa.gov,
	Serge E Hallyn <sergeh@us.ibm.com>, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:1204 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932285AbWF2T3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 15:29:23 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5TJTM6A029651
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 15:29:22 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5TJTMG7252514
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 15:29:22 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5TJTKou006886
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 15:29:22 -0400
In-Reply-To: <20060629.122800.108743929.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you all for your help!  It's been great working with you.

Catherine

David Miller <davem@davemloft.net> wrote on 06/29/2006 03:28:00 PM:

> From: James Morris <jmorris@namei.org>
> Date: Wed, 28 Jun 2006 10:00:48 -0400 (EDT)
> 
> > On Wed, 28 Jun 2006, Catherine Zhang wrote:
> > 
> > > Hi,
> > > 
> > > Minor fix (un-export selinux_get_sock_sid()).
> > 
> > Thanks, looks ok to me.
> > 
> > Acked-by: James Morris <jmorris@namei.org>
> 
> Applied, thanks a lot.

