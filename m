From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [IPROUTE]: Support IPv6 routing table filter
Date: Thu, 10 Aug 2006 13:57:47 -0700
Message-ID: <20060810135747.17e3a900@localhost.localdomain>
References: <44DB9A52.5020501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:42691 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932198AbWHJU5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 16:57:55 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44DB9A52.5020501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 Aug 2006 22:42:58 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Support IPv6 routing table filter in presence of multiple tables,
> f.e. "ip -6 route list table 123". Compatibility is preserved for
> kernels not supporting multiple IPv6 tables.
> 
> 
applied thanks

-- 
