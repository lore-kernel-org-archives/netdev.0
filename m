From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: TSO and IPoIB performance degradation
Date: Mon, 20 Mar 2006 13:27:53 +0200
Message-ID: <20060320112753.GX29929@mellanox.co.il>
References: <20060320090629.GA11352@mellanox.co.il>
	<20060320.015500.72136710.davem@davemloft.net>
	<20060320102234.GV29929@mellanox.co.il>
	<20060320.023704.70907203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rick.jones2@hp.com,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060320.023704.70907203.davem@davemloft.net>
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

Quoting David S. Miller <davem@davemloft.net>:
> I disagree with Linux changing it's behavior.  It would be great to
> turn off congestion control completely over local gigabit networks,
> but that isn't determinable in any way, so we don't do that.

Interesting. Would it make sense to make it another tunable knob in
/proc, sysfs or sysctl then?

-- 
Michael S. Tsirkin
Staff Engineer, Mellanox Technologies
