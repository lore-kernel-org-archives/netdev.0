From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [hyperv] BUG: unable to handle kernel paging request at
 ffff8801f5bc7cbb (netvsc_select_queue)
Date: Fri, 29 Aug 2014 17:13:55 +0000
Message-ID: <2028bb06104a4e2fafdb2e266a064aaf@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <20140829093141.GC11445@sucs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Daniel Borkmann <dborkman@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: Sitsofe Wheeler <sitsofe@gmail.com>, Dexuan Cui <decui@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140829093141.GC11445@sucs.org>
Content-Language: en-US
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



> -----Original Message-----
> From: Sitsofe Wheeler [mailto:sitsofe@gmail.com]
> Sent: Friday, August 29, 2014 2:32 AM
> To: Dexuan Cui
> Cc: KY Srinivasan; Greg Kroah-Hartman; Haiyang Zhang;
> devel@linuxdriverproject.org; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org; David Miller; Daniel Borkmann
> Subject: [hyperv] BUG: unable to handle kernel paging request at
> ffff8801f5bc7cbb (netvsc_select_queue)
> 
> While booting a 10 vcpu system with a post v3.17-rc2 kernel with the
> "Drivers: hv: vmbus: Eliminate calls to BUG_ON()",  "Drivers: hv: vmbus:
> Miscellaneous cleanup" patches and debugging/verification config options on
> I'm seeing the following:

Were you changing the MTU when this occurred?

Regards,

K. Y
