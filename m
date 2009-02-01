From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 1/2] gianfar: Implement proper, per netdevice
	wakeup management
Date: Sun, 01 Feb 2009 00:54:25 -0800 (PST)
Message-ID: <20090201.005425.122181645.davem__10693.9459722073$1233478597$gmane$org@davemloft.net>
References: <20090128203854.GA14693@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, afleming@freescale.com, netdev@vger.kernel.org,
	jgarzik@pobox.com, peppe.cavallaro@st.com
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20090128203854.GA14693@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Wed, 28 Jan 2009 23:38:54 +0300

> This patch implements wakeup management for the gianfar driver.
> 
> The driver should set wakeup enable if WOL is enabled, so that
> phylib won't power off an attached PHY.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied.
