From: davef1624@aol.com
Subject: TCP congestion control for fast, short-distance networks ?
Date: Wed, 04 Apr 2007 11:22:00 -0400
Message-ID: <8C944E41FEE84B1-244-BFF@FWM-D41.sysops.aol.com>
References: <20070403091656.769e5368@localhost.localdomain>	<200704032113.l33LDVhp025035@expredir6.cites.uiuc.edu> <20070404080743.5e67245a@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imo-d05.mx.aol.com ([205.188.157.37]:36875 "EHLO
	imo-d05.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992958AbXDDP16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 11:27:58 -0400
In-Reply-To: <20070404080743.5e67245a@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

We are currently using both 1 Gb & 10 Gb links, that interconnect 
several servers that are very *local* to each other.
Typical RTT times range from 0.2 ms - 0.3 ms.

We are currently using TCP reno - is there a more suitable congestion 
control algorithm for our application,
especially using the 10 Gb links ?
(Most of the High-Speed TCP algorithms seem suitable for large RTT, 
long-distance networks).

Thanks
David

________________________________________________________________________
AOL now offers free email to everyone.  Find out more about what's free 
from AOL at AOL.com.
