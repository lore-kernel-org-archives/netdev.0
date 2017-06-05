From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 2/7] net: pch_gbe: Pull PHY GPIO handling out of
 Minnow code
Date: Mon, 5 Jun 2017 20:55:17 +0200
Message-ID: <20170605185517.GF5235@lunn.ch>
References: <20170602234042.22782-1-paul.burton@imgtec.com>
 <20170605173136.10795-1-paul.burton@imgtec.com>
 <20170605173136.10795-3-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        linux-mips@linux-mips.org, Eric Dumazet <edumazet@google.com>,
        Jarod Wilson <jarod@redhat.com>,
        Tobias Klauser <tklauser@distanz.ch>
To: Paul Burton <paul.burton@imgtec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36933 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751170AbdFESzS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Jun 2017 14:55:18 -0400
Content-Disposition: inline
In-Reply-To: <20170605173136.10795-3-paul.burton@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 05, 2017 at 10:31:31AM -0700, Paul Burton wrote:
> The MIPS Boston development board uses the Intel EG20T Platform
> Controller Hub, including its gigabit ethernet controller, and requires
> that its RTL8211E PHY be reset much like the Minnow platform. Pull the
> PHY reset GPIO handling out of Minnow-specific code such that it can be
> shared by later patches.
> 
> Signed-off-by: Paul Burton <paul.burton@imgtec.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
