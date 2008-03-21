From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take2][NET] ifb: set separate lockdep classes for queue
	locks
Date: Fri, 21 Mar 2008 01:15:36 +0100
Message-ID: <20080321001536.GA22531@ami.dom.local>
References: <20080308120244.GA3378@ami.dom.local> <20080319004547.M71837@visp.net.lb> <20080319073441.GA3918@ff.dom.local> <20080320.153745.232982215.davem@davemloft.net> <20080321000312.GA7755@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, denys@visp.net.lb, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:17354 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbYCUAJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 20:09:07 -0400
Received: by ug-out-1314.google.com with SMTP id z38so1588478ugc.16
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2008 17:09:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080321000312.GA7755@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 21, 2008 at 01:03:12AM +0100, Jarek Poplawski wrote:
...
> IMHO it wastes a bit of memory when lockdep is off and adds some

OOPS! My IMHO is wrong again - no memory is wasted when lockdep is off!

Sorry,
Jarek P.
