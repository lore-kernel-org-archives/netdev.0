From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 00/18] netvsc driver enhancements for net-next
Date: Tue, 24 Jan 2017 14:50:36 -0800
Message-ID: <20170124145036.42f95772@xeon-e3>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
        <20170124.163005.1454633748162819090.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, netdev@vger.kernel.org, sthemmin@microsoft.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34438 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751043AbdAXWut (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 17:50:49 -0500
Received: by mail-pf0-f172.google.com with SMTP id e4so52887750pfg.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 14:50:48 -0800 (PST)
In-Reply-To: <20170124.163005.1454633748162819090.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Jan 2017 16:30:05 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Tue, 24 Jan 2017 13:05:57 -0800
> 
> > Lots of little things in here. Support for minor more ethtool control,
> > negotiation of offload parameters with host (based on FreeBSD) and
> > several cleanups.  
> 
> Series applied, but two comments for potential follow-on changes:

There might be some merge conflicts in linux-next. Nothing drastic but
other vmbus changes are coming through that tree.
