From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Fix build breakage caused by a merge
Date: Tue, 24 Mar 2009 12:07:02 -0700 (PDT)
Message-ID: <20090324.120702.232678762.davem@davemloft.net>
References: <382F4B5D-93C4-41BB-A00A-8A6C240CD170@kernel.crashing.org>
	<20090324153734.GA8276@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, afleming@freescale.com,
	Joakim.Tjernlund@transmode.se, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090324153734.GA8276@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Tue, 24 Mar 2009 18:37:34 +0300

> This patch fixes following build error:
> 
>   CC      ucc_geth.o
> ucc_geth.c: In function 'ucc_geth_probe':
> ucc_geth.c:3644: error: implicit declaration of function 'uec_mdio_bus_name'
> make[2]: *** [ucc_geth.o] Error 1
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied, thanks Anton.
