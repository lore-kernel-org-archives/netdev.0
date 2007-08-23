From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: eHEA driver issues from net-2.6.24
Date: Thu, 23 Aug 2007 09:56:29 +0200
Message-ID: <200708230956.29901.ossthema@de.ibm.com>
References: <20070822.150302.44981242.davem@davemloft.net> <200708230855.29961.ossthema@de.ibm.com> <20070823.011710.01771014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: habanero@us.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:18334 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbXHWI24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 04:28:56 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id l7N8SsSm459272
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 08:28:54 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7N8Ss5J2302072
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 10:28:55 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7N8Ssl7002604
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 10:28:54 +0200
In-Reply-To: <20070823.011710.01771014.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Thursday 23 August 2007 10:17, David Miller wrote:
> From: Jan-Bernd Themann <ossthema@de.ibm.com>
> Date: Thu, 23 Aug 2007 08:55:29 +0200
> 
> > We'd like to keep the possibility to switch back to a single queue
> > for now.
> 
> Please do not do this, we already have way too much configurability
> out there.

ok, we decided to remove the switch for kernel 2.6.24

Regards,
Jan-Bernd
