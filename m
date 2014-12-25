From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Marvell Kirkwood - MV643XX: near 100% UDP RX packet loss
Date: Thu, 25 Dec 2014 13:54:19 -0800
Message-ID: <549C878B.3030308@hp.com>
References: <20141224001844.15e13db8@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?windows-1252?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:44307 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbaLYVyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2014 16:54:25 -0500
In-Reply-To: <20141224001844.15e13db8@neptune.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Why are so many packets being discarded?

You should also check the netstat statistics, particularly UDP on the 
receiving side.  Look before and after the test and see how they change, 
if at all.

rick jones
