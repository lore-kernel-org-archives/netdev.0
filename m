From: Jens Osterkamp <jens@de.ibm.com>
Subject: Re: spidernet: dynamic phy setup code
Date: Thu, 1 Feb 2007 11:50:51 +0100
Message-ID: <200702011150.52199.jens@de.ibm.com>
References: <200701261409.29537.jens@de.ibm.com> <1169842902.24996.108.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org,
	Linas Vepstas <linas@austin.ibm.com>, jgarzik@pobox.com,
	James K Lewis <jim@jklewis.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:15144 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422792AbXBAKu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 05:50:56 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id l11Aorqm070048
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 10:50:53 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l11Aorx71605716
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 11:50:53 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l11AoqAR018052
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 11:50:53 +0100
In-Reply-To: <1169842902.24996.108.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 26 January 2007 9:21 pm, Benjamin Herrenschmidt wrote:

> Can't we have a device-tree property indicating wether to use fiber or
> copper ?

Well, yes, I am sure we could, but what would be the benefit of doing so
if we can get the same information dynamically ?

Jens

