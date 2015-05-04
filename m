From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH] hv_netvsc: remove unused variable in netvsc_send()
Date: Mon, 4 May 2015 21:44:56 +0000
Message-ID: <BN1PR0301MB077063E5445008B80CDAD82CCAD20@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1430762236-18660-1-git-send-email-jsnitsel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Jerry Snitselaar <jsnitsel@redhat.com>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1430762236-18660-1-git-send-email-jsnitsel@redhat.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Jerry Snitselaar [mailto:jsnitsel@redhat.com]
> Sent: Monday, May 4, 2015 10:57 AM
> To: linux-kernel@vger.kernel.org
> Cc: netdev@vger.kernel.org; devel@linuxdriverproject.org; Haiyang Zhang;
> KY Srinivasan
> Subject: [PATCH] hv_netvsc: remove unused variable in netvsc_send()
> 
> With commit b56fc3c53654 ("hv_netvsc: Fix a bug in netvsc_start_xmit()"),
> skb variable is no longer used in netvsc_send. Remove variable and dead
> code that depended on it.
> 
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: K. Y. Srinivasan <kys@microsoft.com>
> Signed-off-by: Jerry Snitselaar <jsnitsel@redhat.com>

Thanks.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
