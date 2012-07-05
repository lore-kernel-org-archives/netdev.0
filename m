From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] cnic: Fix mmap regression.
Date: Thu, 5 Jul 2012 16:34:18 -0700
Message-ID: <1341531258.7472.27.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1340998365-15753-1-git-send-email-mchan@broadcom.com>
 <20120629.153425.24594752441419170.davem@davemloft.net>
 <1341525586.7472.25.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <20120705.153638.790030674286651971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4703 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753476Ab2GEXeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2012 19:34:25 -0400
In-Reply-To: <20120705.153638.790030674286651971.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 15:36 -0700, David Miller wrote: 
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Thu, 5 Jul 2012 14:59:46 -0700
> 
> > Or you want me to send you the equivalent patches for net.
> 
> Please do so.
> 

OK.  I'll send you one patch to fix it in net, instead of one that
causes regression, and another one to fix it.
