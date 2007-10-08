From: David Miller <davem@davemloft.net>
Subject: Re: pktgen question
Date: Mon, 08 Oct 2007 15:54:48 -0700 (PDT)
Message-ID: <20071008.155448.91337942.davem@davemloft.net>
References: <470AA7B9.4070703@candelatech.com>
	<20071008.152234.13748626.davem@davemloft.net>
	<470AB342.1030209@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, rick.jones2@hp.com, hadi@cyberus.ca,
	johnpol@2ka.mipt.ru, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se
To: swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36523
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751759AbXJHWyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 18:54:49 -0400
In-Reply-To: <470AB342.1030209@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise@opengridcomputing.com>
Date: Mon, 08 Oct 2007 17:46:26 -0500

> We're talking about just for pktgen...eh?

My bad, I'm happy to review a patch that uses the
skb->destructor in pktgen to achieve this.

