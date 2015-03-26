From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 2/6] pass phy_device instead of net_device to fixed_phy
 link_update() function
Date: Thu, 26 Mar 2015 23:59:02 +0100
Message-ID: <20150326235902.5f9efc70@free-electrons.com>
References: <55142C31.5050504@list.ru>
	<55142CB1.1080107@list.ru>
	<55142D01.3090601@list.ru>
	<20150326.154901.1917521749865418277.davem@davemloft.net>
	<55148E65.4020103@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:56838 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753333AbbCZW7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 18:59:40 -0400
In-Reply-To: <55148E65.4020103@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Stas Sergeev,

On Fri, 27 Mar 2015 01:55:33 +0300, Stas Sergeev wrote:

> I'll remove the silly thunderbird-patch-inline plugin (that adds this line)
> and will try to convince thunderbird not to break indentation, oh...

Or you start using 'git send-email', which will do the right thing for
you.

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
