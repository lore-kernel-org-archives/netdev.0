From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/3] net: dsa: lan9303: Add STP ALR entry on
 port 0
Date: Wed, 1 Nov 2017 13:04:18 +0100
Message-ID: <20171101120418.GB12680@lunn.ch>
References: <20171031144802.12686-1-privat@egil-hjelmeland.no>
 <20171031144802.12686-3-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171031144802.12686-3-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 31, 2017 at 03:48:01PM +0100, Egil Hjelmeland wrote:
> STP BPDUs arriving on user ports must sent to CPU port only,
> for processing by the SW bridge.
> 
> Add an ALR entry with STP state override to fix that.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
