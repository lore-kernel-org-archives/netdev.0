From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] mrf24j40: separate h/w
	init and add checkings
Date: Tue, 17 Jun 2014 15:31:36 -0700 (PDT)
Message-ID: <20140617.153136.653057237840817486.davem@davemloft.net>
References: <1402890152-2803-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: varkab-If5XQcfNmg0@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: varkabhadram-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1402890152-2803-1-git-send-email-varkab-If5XQcfNmg0@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Varka Bhadram <varkabhadram-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 16 Jun 2014 09:12:31 +0530

> separate the mrf24j40 hardware initialisation from probe()
> and adds the sanity checkings.
> 
> These checkings are required if somebody hasn't a right spi configuration
> the probe function should fail. So we have to return from there.
> 
> Signed-off-by: Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>

Applied.

------------------------------------------------------------------------------
HPCC Systems Open Source Big Data Platform from LexisNexis Risk Solutions
Find What Matters Most in Your Big Data with HPCC Systems
Open Source. Fast. Scalable. Simple. Ideal for Dirty Data.
Leverages Graph Analysis for Fast Processing & Easy Data Exploration
http://p.sf.net/sfu/hpccsystems
