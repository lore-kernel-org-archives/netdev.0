From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,1/1] hyperv: Add support for setting MAC from
 within guests
Date: Mon, 16 Jul 2012 22:54:53 -0700 (PDT)
Message-ID: <20120716.225453.1695509038616478796.davem@davemloft.net>
References: <1341940762-18307-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, olaf@aepfle.de, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1341940762-18307-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue, 10 Jul 2012 10:19:22 -0700

> This adds support for setting synthetic NIC MAC address from within Linux
> guests. Before using this feature, the option "spoofing of MAC address"
> should be enabled at the Hyper-V manager / Settings of the synthetic
> NIC.
> 
> Thanks to Kin Cho <kcho@infoblox.com> for the initial implementation and
> tests. And, thanks to Long Li <longli@microsoft.com> for the debugging
> works.
> 
> Reported-and-tested-by: Kin Cho <kcho@infoblox.com>
> Reported-by: Long Li <longli@microsoft.com>
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied to net-next, thanks.
