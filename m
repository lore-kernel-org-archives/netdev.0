From: Carlos Carvalho <carlos@fisica.ufpr.br>
Subject: IPv6 DNSSL (rfc6106): please include the patch to pass it to user space
Date: Mon, 6 Jun 2011 13:29:11 -0300
Message-ID: <19949.87.934341.698604@fisica.ufpr.br>
References: <20080328092036.GA11924@2ka.mipt.ru>
	<20080328.134053.122172549.davem@davemloft.net>
	<20080328205613.GA24812@2ka.mipt.ru>
	<20080328.140736.92315090.davem@davemloft.net>
	<20080328215131.GB24812@2ka.mipt.ru>
	<20080401164904.GA2382@2ka.mipt.ru>
	<20080408122545.GA31729@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fisica.ufpr.br ([200.17.209.129]:58205 "EHLO fisica.ufpr.br"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755498Ab1FFQjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 12:39:06 -0400
In-Reply-To: <20080408122545.GA31729@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the kernel doesn't pass DNSSL lists received by router
advertsiments (rfc 6106) to user space via netlink. Pierre Ossman sent
a patch for it about 6 months ago:
http://patchwork.ozlabs.org/patch/75243. Could you please include it
in mainline? This is a very useful feature.
