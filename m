From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: abstract VTU/STU
 data access
Date: Wed, 11 May 2016 19:34:36 -0400 (EDT)
Message-ID: <20160511.193436.479917073818481033.davem@davemloft.net>
References: <1462909469-4827-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462909469-4827-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 10 May 2016 15:44:28 -0400

> Both VTU and STU operations use the same routine to access their
> (common) data registers, with a different offset.
> 
> Add VTU and STU specific read and write functions to the data registers
> to abstract the required offset.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
