From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] ss: Include -E option for socket destroy
 events
Date: Fri, 26 Jun 2015 00:21:00 -0400
Message-ID: <20150626002100.7eff28d0@uryu.home.lan>
References: <1434554088-10200-1-git-send-email-kraig@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: Craig Gallek <kraig@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:35677 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800AbbFZEVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 00:21:23 -0400
Received: by obbop1 with SMTP id op1so59932273obb.2
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 21:21:22 -0700 (PDT)
In-Reply-To: <1434554088-10200-1-git-send-email-kraig@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Jun 2015 11:14:48 -0400
Craig Gallek <kraig@google.com> wrote:

> Use the IPv4/IPv6/TCP/UDP multicast groups of NETLINK_SOCK_DIAG
> to filter and display socket statistics as they are destroyed.
> 
> Kernel support patch series: 24029a3603cfa633e8bc2b3fb3e48e76c497831d
> 
> Signed-off-by: Craig Gallek <kraig@google.com>

Accepted. Currently sitting on local net-next branch until after merge.
