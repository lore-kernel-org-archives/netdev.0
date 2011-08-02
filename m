From: Rick Jones <rick.jones2@hp.com>
Subject: Re: data vs overhead bytes, netperf aggregate RR and retransmissions
Date: Tue, 02 Aug 2011 15:12:29 -0700
Message-ID: <4E38764D.6050803@hp.com>
References: <4E386E98.1090606@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:8796 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755501Ab1HBWMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2011 18:12:30 -0400
Received: from g1t0038.austin.hp.com (g1t0038.austin.hp.com [16.236.32.44])
	by g1t0028.austin.hp.com (Postfix) with ESMTP id 6FCB31C37A
	for <netdev@vger.kernel.org>; Tue,  2 Aug 2011 22:12:30 +0000 (UTC)
Received: from [16.89.244.213] (tardy.cup.hp.com [16.89.244.213])
	by g1t0038.austin.hp.com (Postfix) with ESMTP id 4FFEC300BE
	for <netdev@vger.kernel.org>; Tue,  2 Aug 2011 22:12:30 +0000 (UTC)
In-Reply-To: <4E386E98.1090606@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2011 02:39 PM, Rick Jones wrote:
>  but if the inbound DMA buffers were 2048
> bytes in size, 48 (49 actually, the "burst" is added to the one done by
> default) of them would fill 86KB - so would 40,

Please disregard the silly math error about 40, 2048 byte buffers 
filling 86KB...

rick
