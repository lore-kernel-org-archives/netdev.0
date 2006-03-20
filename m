From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: TSO and IPoIB performance degradation
Date: Mon, 20 Mar 2006 15:35:54 +0200
Message-ID: <20060320133554.GA29929@mellanox.co.il>
References: <20060320090629.GA11352@mellanox.co.il>
	<20060320.015500.72136710.davem@davemloft.net>
	<20060320102234.GV29929@mellanox.co.il>
	<20060320.023704.70907203.davem@davemloft.net>
	<20060320112753.GX29929@mellanox.co.il>
	<1142855223.3114.30.camel@laptopd505.fenrus.org>
	<20060320114933.GA3058@xi.wantstofly.org>
	<1142855615.3114.33.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rick.jones2@hp.com,
	linux-kernel@vger.kernel.org, openib-general@openib.org,
	"David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <openib-general-bounces@openib.org>
To: Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
In-Reply-To: <1142855615.3114.33.camel@laptopd505.fenrus.org>
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

Quoting Arjan van de Ven <arjan@infradead.org>:
> > I read it as if he was proposing to have a sysctl knob to turn off
> > TCP congestion control completely (which has so many issues it's not
> > even funny.)
> 
> owww that's so bad I didn't even consider that

No, I think that comment was taken out of thread context. We were talking about
stretching ACKs - while avoiding stretch ACKs is important for TCP congestion
control, it's not the only mechanism.

-- 
Michael S. Tsirkin
Staff Engineer, Mellanox Technologies
