From: "kiran kandi" <kkiran78@hotmail.com>
Subject: hard_start_xmit  conext
Date: Tue, 15 Aug 2006 19:12:09 +0000
Message-ID: <BAY119-F167D4D4A8CA125150C0A60D44F0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s34.bay0.hotmail.com ([65.54.246.106]:32162 "EHLO
	bay0-omc1-s34.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1030464AbWHOTMu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 15:12:50 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

In what context hard_start_xmit  function is called. Is it called in soft 
irq or a  processes context.

Also can you call kfree_skb in  soft irq context.

--
Thanks
kiran

_________________________________________________________________
On the road to retirement? Check out MSN Life Events for advice on how to 
get there! http://lifeevents.msn.com/category.aspx?cid=Retirement

