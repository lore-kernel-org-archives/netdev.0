From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH v2 net-next] net: ipv6: Add a sysctl to make optimistic
 addresses useful candidates
Date: Wed, 29 Oct 2014 00:15:39 +0900
Message-ID: <CAKD1Yr2PSJ0=YV4m5jPyvt6cvNv8+-joft6L2DxO_5YLH6C7AQ@mail.gmail.com>
References: <1414487474-18201-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:60233 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbaJ1PP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 11:15:59 -0400
Received: by mail-ig0-f182.google.com with SMTP id hn18so1228444igb.3
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 08:15:59 -0700 (PDT)
In-Reply-To: <1414487474-18201-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2014 at 6:11 PM, Erik Kline <ek@google.com> wrote:
> Add a sysctl that causes an interface's optimistic addresses
> to be considered equivalent to other non-deprecated addresses
> for source address selection purposes.  Preferred addresses
> will still take precedence over optimistic addresses, subject
> to other ranking in the source address selection algorithm.
> ...
> Signed-off-by: Erik Kline <ek@google.com>

Acked-by: Lorenzo Colitti <lorenzo@google.com>
