From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: abstract VTU/STU data
 access
Date: Tue, 10 May 2016 23:29:42 +0200
Message-ID: <20160510212942.GA24788@lunn.ch>
References: <1462909469-4827-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1462909469-4827-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 10, 2016 at 03:44:28PM -0400, Vivien Didelot wrote:
> Both VTU and STU operations use the same routine to access their
> (common) data registers, with a different offset.
> 
> Add VTU and STU specific read and write functions to the data registers
> to abstract the required offset.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Hi Vivien

Improves the readability.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew
