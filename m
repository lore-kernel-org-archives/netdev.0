From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [PATCH] gianfar: Fix build with CONFIG_NET_POLL_CONTROLLER=y
Date: Wed, 9 Dec 2009 19:25:00 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BA08A9A@zin33exm22.fsl.freescale.net>
References: <1260341804.16132.22.camel@pasglop><20091209104427.GA25526@oksana.dev.rtsoft.ru>
	<20091209.025245.152622485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: <avorontsov@ru.mvista.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-class: urn:content-classes:message
In-Reply-To: <20091209.025245.152622485.davem@davemloft.net>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

 
>From: Anton Vorontsov <avorontsov@ru.mvista.com>
>Date: Wed, 9 Dec 2009 13:44:27 +0300
>
>> commit 46ceb60ca80fa07703bc6eb8f4651f900dff5a82 ("gianfar: Add 
>> Multiple group Support") introduced the following build error with 
>> CONFIG_NET_POLL_CONTROLLER=y:
> ...
>> This patch fixes the issue.
>> 
>> Reported-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
>

Thanks Anton !
