From: Jens Osterkamp <jens@de.ibm.com>
Subject: Re: [PATCH] spidernet : fix memory leak in spider_net_stop
Date: Thu, 1 Feb 2007 21:40:10 +0100
Message-ID: <200702012140.10877.jens@de.ibm.com>
References: <200702011207.47421.jens@de.ibm.com> <20070201173618.GI5616@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: James K Lewis <jim@jklewis.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, jgarzik@pobox.com, cbe-oss-dev@ozlabs.org,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:15071 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422988AbXBAUkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 15:40:45 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l11KeOig190412
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 20:40:24 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l11KeOrC970796
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 20:40:24 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l11KeNcx006736
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 20:40:24 GMT
In-Reply-To: <20070201173618.GI5616@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 01 February 2007 6:36 pm, Linas Vepstas wrote:
> 
> A variant of this patch is queued up for 2.6.21,
> as a part of the patch
> http://www.mail-archive.com/netdev@vger.kernel.org/msg28213.html
> 
> I beleive its in the -mm tree, I have not checked.

Ah, good ! I knew that you had several patches in the queue but wasnt aware
of the detailed content.

Jens
