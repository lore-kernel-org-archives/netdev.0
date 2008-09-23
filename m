From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/4] mISDN: endian annotations for struct zt
Date: Mon, 22 Sep 2008 19:16:31 -0700 (PDT)
Message-ID: <20080922.191631.178065641.davem@davemloft.net>
References: <200809222151.m8MLp2iv031898@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kkeil@suse.de, netdev@vger.kernel.org, harvey.harrison@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54418
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753978AbYIWCQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:16:43 -0400
In-Reply-To: <200809222151.m8MLp2iv031898@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 22 Sep 2008 14:51:02 -0700

> Found two possible bugs where the z1 value was used directly without
> byteswapping.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-next-2.6
