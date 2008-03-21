From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [net-2.6.26 patch 0/6][NETNS][IPV6] handling more proc per namespace
Date: Fri, 21 Mar 2008 11:59:49 +0100
Message-ID: <47E39525.5070603@fr.ibm.com>
References: <20080313114609.176640638@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:12955 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544AbYCULAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 07:00:21 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2LB0K6W176544
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 11:00:20 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2LB0Khm1622178
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 12:00:20 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2LB0Jqc016534
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 12:00:20 +0100
In-Reply-To: <20080313114609.176640638@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> This patchset makes tcp6/udp6 to have their proc files to be per
> namespace. This is useful for netstat :)  
> It fixes also a compilation warning for multicast.
> 

Hi David,

I sent this patchset more than 1 week ago, I know you were very busy 
with your presentations in Japan. Shall I resend them ? or do you have 
them in your backlog ?

  -- Daniel
