From: Liew Kian Yang <kianyang@agroup.com.my>
Subject: Re: Vlan communication
Date: Wed, 17 Nov 2010 17:57:07 +0800
Message-ID: <1289987827.4215.3.camel@localhost.localdomain>
References: <1289978124.3250.2.camel@localhost.localdomain>
 <1289893935.3364.255.camel@edumazet-laptop>
Reply-To: kianyang@agroup.com.my
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from venus.localdns.com ([202.190.203.180]:54185 "EHLO
	dedge-246.localdns.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932509Ab0KPJ6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 04:58:52 -0500
Received: from mercury.localdns.com (venus.localdns.com [202.190.203.180])
	by dedge-246.localdns.com (Postfix) with ESMTP id C3B6912E8C8
	for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 17:58:48 +0800 (MYT)
Received: from [192.168.8.98] ([175.136.197.14])
 by mercury.localdns.com (Sun Java System Messaging Server 6.2-4.03 (built Sep
 22 2005)) with ESMTPA id <0LBZ009DQ2E0BV30@mercury.localdns.com> for
 netdev@vger.kernel.org; Tue, 16 Nov 2010 17:58:49 +0800 (MYT)
In-reply-to: <1289893935.3364.255.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Eric,

My question is, can i have vlan function enable without using the
vconfig command?

Thank you


Regards,
Kian Yang, Liew

On Tue, 2010-11-16 at 08:52 +0100, Eric Dumazet wrote:
> ip link add link eth0 eth0.1 type vlan id 1
> 
> 
> 

