From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: dsa: lan9303: Move struct lan9303 to
 include/linux/lan9303.h
Date: Tue, 24 Oct 2017 18:31:55 +0200
Message-ID: <20171024163155.GB12347@lunn.ch>
References: <20171024093515.6749-1-privat@egil-hjelmeland.no>
 <20171024093515.6749-2-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171024093515.6749-2-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2017 at 11:35:14AM +0200, Egil Hjelmeland wrote:
> The next patch require net/dsa/tag_lan9303.c to access struct lan9303.
> Therefore move struct lan9303 definitions from drivers/net/dsa/lan9303.h
> to new file include/linux/lan9303.h.
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

O.K, so not too bad.

I am now however wondering if include/linux/dsa/lan9303.h would be
better?

Anyway,

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
