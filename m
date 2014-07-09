From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] hyperv: Add netpoll support
Date: Wed, 09 Jul 2014 16:53:26 -0700 (PDT)
Message-ID: <20140709.165326.390545212542541507.davem@davemloft.net>
References: <1404915839-15940-1-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
 haiyangz@microsoft.com, linux-kernel@vger.kernel.org, romieu@fr.zoreil.com,
 devel@linuxdriverproject.org
To: richard@nod.at
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1404915839-15940-1-git-send-email-richard@nod.at>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Richard Weinberger <richard@nod.at>
Date: Wed,  9 Jul 2014 16:23:59 +0200

> In order to have at least a netconsole to debug kernel issues on
> Windows Azure this patch implements netpoll support.
> Sending packets is easy, netvsc_start_xmit() does already everything
> needed.
> 
> Signed-off-by: Richard Weinberger <richard@nod.at>

Applied to net-next, thanks.
