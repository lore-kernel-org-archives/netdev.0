From: Phil Sutter <psutter@redhat.com>
Subject: Re: [iproute PATCH] ip-route: Prevent some other double spaces in
 output
Date: Fri, 7 Apr 2017 16:16:07 +0200
Message-ID: <20170407141607.GW19768@orbyte.nwl.cc>
References: <d73d016dbf5c81869e4fe745b9223fd726f1c43a.1491410198.git.tredaelli@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
To: Timothy Redaelli <tredaelli@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35193 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754189AbdDGOQI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 10:16:08 -0400
Content-Disposition: inline
In-Reply-To: <d73d016dbf5c81869e4fe745b9223fd726f1c43a.1491410198.git.tredaelli@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 05, 2017 at 07:10:26PM +0200, Timothy Redaelli wrote:
> Print spaces only after text.
> 
> CC: Phil Sutter <phil@nwl.cc>
> Signed-off-by: Timothy Redaelli <tredaelli@redhat.com>

Acked-by: Phil Sutter <phil@nwl.cc>

> Fixed all the problems reported in V2
> 
> Tested with improved script https://da.gd/tUVso that tests ip route and ip get
> for both ipv4 and ipv6.
> 
> If it's OK I'd like to send it upstream

This is obviously a leftover from internal review. :)

Cheers, Phil
