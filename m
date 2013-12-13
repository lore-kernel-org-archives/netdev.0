From: Li Zhong <zhong@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 net-next] packet: fix using smp_processor_id() in
 preemptible code
Date: Fri, 13 Dec 2013 09:49:45 +0800
Message-ID: <1386899385.3575.2.camel@ThinkPad-T5421>
References: <1386828604.2584.13.camel@ThinkPad-T5421>
	 <52A83699.9010504@redhat.com>	<1386888664.2586.3.camel@ThinkPad-T5421>
	 <20131212.161523.1172258207723966525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:38453 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566Ab3LMBt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 20:49:56 -0500
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zhong@linux.vnet.ibm.com>;
	Fri, 13 Dec 2013 11:49:53 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 3D9202BB002D
	for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 12:49:50 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBD1VQGK1704434
	for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 12:31:26 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBD1nmDV020076
	for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 12:49:48 +1100
In-Reply-To: <20131212.161523.1172258207723966525.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-12 at 16:15 -0500, David Miller wrote:
> From: Li Zhong <zhong@linux.vnet.ibm.com>
> Date: Fri, 13 Dec 2013 06:51:04 +0800
> 
> Please fix the date on your computer.
> 
Oh, sorry about that, should be fixed this time. 

I saw Daniel helped to send one with the correct date.

Thanks, Zhong
