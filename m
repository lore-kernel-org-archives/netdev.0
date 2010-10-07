From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: bluetooth-2.6 2010-10-05
Date: Thu, 07 Oct 2010 01:02:18 -0700 (PDT)
Message-ID: <20101007.010218.57483410.davem@davemloft.net>
References: <20101005171349.GA16520@vigoh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, marcel@holtmann.org,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: padovan@profusion.mobi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49446
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759212Ab0JGIB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 04:01:56 -0400
In-Reply-To: <20101005171349.GA16520@vigoh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Date: Tue, 5 Oct 2010 14:13:49 -0300

> In this patch set we have two fixes for regressions in L2CAP due to ERTM code
> we added in L2CAP for 2.6.36, a bugfix in the L2CAP Streaming Mode that was
> making the kernel crash. And a fix for a deadlock issue between the sk_sndbuf
> and the backlog queue in ERTM. The rest are also needed bug fixes.

Pulled, thanks.
