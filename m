From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ipadress: fix display of IPv6 peer address
Date: Fri, 26 Jul 2013 14:27:49 -0700
Message-ID: <20130726142749.434de24e@nehalam.linuxnetplumber.net>
References: <1374007968-11287-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:44996 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932831Ab3GZVbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 17:31:21 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so2459739pbb.8
        for <netdev@vger.kernel.org>; Fri, 26 Jul 2013 14:31:21 -0700 (PDT)
In-Reply-To: <1374007968-11287-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Jul 2013 22:52:48 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Because only IPv4 was supported, the size was static. Now, IPv6 also supports
> peer address.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
