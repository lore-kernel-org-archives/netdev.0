From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix comparisons of unsigned < 0
Date: Thu, 31 May 2007 21:33:52 -0700 (PDT)
Message-ID: <20070531.213352.109885494.davem@davemloft.net>
References: <20070530075613.GA29081@nostromo.devel.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: notting@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35642
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751149AbXFAEdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 00:33:39 -0400
In-Reply-To: <20070530075613.GA29081@nostromo.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bill Nottingham <notting@redhat.com>
Date: Wed, 30 May 2007 03:56:13 -0400

> Recent gcc versions emit warnings when unsigned variables are compared < 0 or >= 0.
> 
> Signed-off-by: Bill Nottingham <notting@redhat.com>

Patch applied, thanks.
