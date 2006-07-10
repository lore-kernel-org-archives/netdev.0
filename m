From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: [PATCH] IB/mthca: comment fix
Date: Mon, 10 Jul 2006 14:59:55 +0300
Message-ID: <20060710115955.GF24705@mellanox.co.il>
References: <1152531909.4874.22.camel@laptopd505.fenrus.org>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>,
	Zach Brown <zach.brown@oracle.com>, openib-general@openib.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxl145v68.mxlogic.net ([208.65.145.68]:48550 "EHLO
	p02c11o145.mxlogic.net") by vger.kernel.org with ESMTP
	id S964934AbWGJL7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 07:59:36 -0400
To: Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
In-Reply-To: <1152531909.4874.22.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting r. Arjan van de Ven <arjan@infradead.org>:
> makes sense to me; my main concern is that we document the bug that was
> there; unless you document such things.. these bugs tend to have a habit
> of resurfacing later ;)

Right. Although lockdep will catch this one quickly :)

-- 
MST
