From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: Timeline of IPoIB performance
Date: Mon, 10 Oct 2005 22:03:22 +0200
Message-ID: <20051010200321.GC6633@mellanox.co.il>
References: <521x2tgrim.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <rolandd@cisco.com>
Content-Disposition: inline
In-Reply-To: <521x2tgrim.fsf@cisco.com>
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

Hi Roland,

Quoting r. Roland Dreier <rolandd@cisco.com>:
> However, I haven't been able to get numbers that are stable enough to
> track this down. 

Disabling irq balancing sometimes helps me make the numbers more stable.
Hope this helps,

-- 
MST
