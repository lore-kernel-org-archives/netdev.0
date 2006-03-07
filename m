From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: Re: TSO and IPoIB performance degradation
Date: Tue, 7 Mar 2006 23:53:22 +0200
Message-ID: <20060307215322.GD20703@mellanox.co.il>
References: <OF336D72E6.999D2A30-ON8725712A.00117C92-8825712A.00116629@us.ibm.com>
	<1141767891.6119.903.camel@localhost>
	<20060307134907.733d3d27@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	openib-general@openib.org, "David S. Miller" <davem@davemloft.net>
Return-path: <openib-general-bounces@openib.org>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060307134907.733d3d27@localhost.localdomain>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Quoting r. Stephen Hemminger <shemminger@osdl.org>:
> Is IB using NAPI or just doing netif_rx()?

No, IPoIB doesn't use NAPI.

-- 
Michael S. Tsirkin
Staff Engineer, Mellanox Technologies
