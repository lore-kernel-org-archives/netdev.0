From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,v2] hyperv: Add processing of MTU reduced by
 the host
Date: Wed, 12 Nov 2014 16:21:52 -0500 (EST)
Message-ID: <20141112.162152.2094776975747538960.davem@davemloft.net>
References: <1415830064-1440-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1415830064-1440-1-git-send-email-haiyangz@microsoft.com>
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

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Wed, 12 Nov 2014 14:07:44 -0800

> If the host uses packet encapsulation feature, the MTU may be reduced by the
> host due to headroom reservation for encapsulation. This patch handles this
> new MTU value.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied, thanks for adding the comment.
