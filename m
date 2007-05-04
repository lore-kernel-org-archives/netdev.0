From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [AF_IUCV/IUCV] : Add missing section annotations
Date: Fri, 04 May 2007 12:24:19 -0700 (PDT)
Message-ID: <20070504.122419.28789261.davem@davemloft.net>
References: <20070428.230626.79066898.davem@davemloft.net>
	<20070504094652.GA22917@de.ibm.com>
	<20070504095238.GB32153@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: fpavlic@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52338
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423043AbXEDTYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 15:24:33 -0400
In-Reply-To: <20070504095238.GB32153@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank Pavlic <fpavlic@de.ibm.com>
Date: Fri, 4 May 2007 11:52:38 +0200

> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Add missing section annotations and found and fixed some
> Coding Style issues.
> 
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>

Applied, although I find it amusing that the changelog
header talks about section annotations (plural!) but
that is one line of the patch, whereas %99 of the patch
is coding style cleanups.
