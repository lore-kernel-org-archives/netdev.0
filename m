From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/3] jme: Adding lock to protect vlgrp
 structure.
Date: Tue, 16 Mar 2010 00:55:16 -0700 (PDT)
Message-ID: <20100316.005516.199857750.davem@davemloft.net>
References: <1268630108-10374-2-git-send-email-cooldavid@cooldavid.org>
	<20100315.155453.143098808.davem@davemloft.net>
	<20100316071753.M36702@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ethanhsiao@jmicron.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42084
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936551Ab0CPHyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 03:54:54 -0400
In-Reply-To: <20100316071753.M36702@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Tue, 16 Mar 2010 15:49:45 +0800

> BTW, is it OK if the patch can only apply on net-2.6 tree cleanly,
> but have some Hunks applying to stable kernel? If it is intended
> for both net-2.6 and stable kernel.

Sure.
