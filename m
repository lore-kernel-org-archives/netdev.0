From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH 1/2] udp:  add tracepoints for queueing skb to rcvbuf
Date: Tue, 21 Jun 2011 13:58:27 +0200
Message-ID: <4123e3d3ce0192e63947178f249d3411@localhost>
References: <65795E11DBF1E645A09CEC7EAEE94B9C402B96E4@USINDEVS02.corp.hds.com>
 <65795E11DBF1E645A09CEC7EAEE94B9C402B96E5@USINDEVS02.corp.hds.com>
 <20110621104742.GA16311@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Satoru Moriya <satoru.moriya@hds.com>, <netdev@vger.kernel.org>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:50431 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751166Ab1FUL6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 07:58:30 -0400
In-Reply-To: <20110621104742.GA16311@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 21 Jun 2011 06:47:43 -0400, Neil Horman wrote:



> I was thinking you could just trace callers of __sk_mem_schedule, but

> looking at

> it this works as well

> Acked-by: Neil Horman <nhorman@tuxdriver.com>



Hey Neil,



since you acked the patch do you have any plans to migrate dropwatch to

use perf infrastructure and skip the netlink transport? Should be

practicable now. No kernel patch required to run dropwatch ;-)





HGN


