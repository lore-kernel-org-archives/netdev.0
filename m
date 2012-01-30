From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] ss: should support CONFIG_INET_UDP_DIAG=n
 kernels
Date: Mon, 30 Jan 2012 08:13:43 -0800
Message-ID: <20120130081343.1d05ba13@nehalam.linuxnetplumber.net>
References: <1327939545.2297.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@parallels.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43807 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753851Ab2A3QNq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jan 2012 11:13:46 -0500
In-Reply-To: <1327939545.2297.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jan 2012 17:05:45 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> ss -x currently fails if CONFIG_INET_UDP_DIAG=n or old kernels
> 
> Also close file descriptors while we are at it.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>

applied
