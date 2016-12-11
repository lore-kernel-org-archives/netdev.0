From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] net: bridge: fast ageing on topology
	change
Date: Sat, 10 Dec 2016 21:55:12 -0500 (EST)
Message-ID: <20161210.215512.1243458025069409442.davem@davemloft.net>
References: <20161210184429.31600-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: idosch@mellanox.com, andrew@lunn.ch, f.fainelli@gmail.com,
	nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	jiri@mellanox.com, kernel@savoirfairelinux.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20161210184429.31600-1-vivien.didelot@savoirfairelinux.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Sat, 10 Dec 2016 13:44:26 -0500

> 802.1D [1] specifies that the bridges in a network must use a short
> value to age out dynamic entries in the Filtering Database for a period,
> once a topology change has been communicated by the root bridge.
> 
> This patchset fixes this for the in-kernel STP implementation.
 ...

Series applied.
