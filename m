From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net] net/mlx4_en: correct the endianness of doorbell_qpn
 on big endian platform
Date: Mon, 8 Dec 2014 11:12:29 +0800
Message-ID: <20141208031229.GA13949@richard>
References: <1417315431-16761-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20141205.213112.1199355931404701216.davem@davemloft.net>
 <1417844801.15618.30.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, weiyang@linux.vnet.ibm.com,
	netdev@vger.kernel.org, gideonn@mellanox.com, edumazet@google.com,
	amirv@mellanox.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:41983 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851AbaLHDMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 22:12:43 -0500
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 8 Dec 2014 13:12:37 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 9C24E2CE8054
	for <netdev@vger.kernel.org>; Mon,  8 Dec 2014 14:12:33 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sB83CWRT23724284
	for <netdev@vger.kernel.org>; Mon, 8 Dec 2014 14:12:33 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sB83CVmx012037
	for <netdev@vger.kernel.org>; Mon, 8 Dec 2014 14:12:32 +1100
Content-Disposition: inline
In-Reply-To: <1417844801.15618.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 05, 2014 at 09:46:41PM -0800, Eric Dumazet wrote:
>On Fri, 2014-12-05 at 21:31 -0800, David Miller wrote:
>
>> Guys, let's figure out what we are doing with this patch.
>> --
>
>Oh well, patch is fine, please apply it, thanks !

Thanks :-)

>
>

-- 
Richard Yang
Help you, Help me
