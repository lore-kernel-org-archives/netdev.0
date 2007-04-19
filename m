From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [GIT PATCH] Exporting IPv6 statistics via netlink.
Date: Thu, 19 Apr 2007 10:44:12 +0200
Message-ID: <20070419084412.GD521@postel.suug.ch>
References: <20070419.154209.131781981.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56462 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161217AbXDSInw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2007 04:43:52 -0400
Content-Disposition: inline
In-Reply-To: <20070419.154209.131781981.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@linux-ipv6.org> 2007-04-19 15:42
> 
> Please consider pulling following changesets for supporting exporting
> stats information via netlink, on top of net-2.6.22.

The netlink bits are perfectly fine, why the dependency on proc fs?
