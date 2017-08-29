From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2] bridge: fdb add and delete tracepoints
Date: Tue, 29 Aug 2017 15:36:48 +0200
Message-ID: <20170829133648.GF22093@lunn.ch>
References: <1503980568-35240-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        nikolay@cumulusnetworks.com, f.fainelli@gmail.com,
        bridge@lists.linux-foundation.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43106 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752060AbdH2Ngx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 09:36:53 -0400
Content-Disposition: inline
In-Reply-To: <1503980568-35240-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 09:22:48PM -0700, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> A few useful tracepoints to trace bridge forwarding
> database updates.

Hi Roopa

Once accepted, it would be nice to add mdb tracepoints as well. I
expect the implementation would be very similar.

       Andrew
