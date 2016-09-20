From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip: (ipvlan) introduce L3s mode
Date: Tue, 20 Sep 2016 09:51:22 -0700
Message-ID: <20160920095122.74b04401@xeon-e3>
References: <1474321180-31717-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35748 "EHLO
        mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754694AbcITQvM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:51:12 -0400
Received: by mail-pa0-f51.google.com with SMTP id oz2so8787816pac.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 09:51:12 -0700 (PDT)
In-Reply-To: <1474321180-31717-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Sep 2016 14:39:40 -0700
Mahesh Bandewar <mahesh@bandewar.net> wrote:

> From: Mahesh Bandewar <maheshb@google.com>
> 
> The new mode 'l3s' can be set like -
> 
>   ip link add link <master> dev <IPvlan-slave> type ipvlan mode l3s
> 
>   e.g. ip link add link eth0 dev ipvl0 type ipvlan mode l3s
> 
> Also did some trivial code restructuring.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied to net-next
