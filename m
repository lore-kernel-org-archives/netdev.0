From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] phy: micrel.c: Enable ksz9031 energy-detect
 power-down mode
Date: Tue, 4 Oct 2016 08:55:54 +0200
Message-ID: <20161004065554.GB6097@lunn.ch>
References: <1475499870-11465-1-git-send-email-mike.looijmans@topic.nl>
 <1475560324-23346-1-git-send-email-mike.looijmans@topic.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        linux-kernel@vger.kernel.org
To: Mike Looijmans <mike.looijmans@topic.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1475560324-23346-1-git-send-email-mike.looijmans@topic.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 04, 2016 at 07:52:04AM +0200, Mike Looijmans wrote:
> Set bit 0 in register 1C.23 to enable the EDPD feature of the
> KSZ9031 PHY. This reduces power consumption when the link is
> down.
> 
> Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
