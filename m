From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Drivers: net-next: hyperv
Date: Wed, 30 Jul 2014 17:25:23 -0700 (PDT)
Message-ID: <20140730.172523.1080858143706717134.davem@davemloft.net>
References: <1406769616-29871-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1406769616-29871-1-git-send-email-kys@microsoft.com>
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

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Wed, 30 Jul 2014 18:20:16 -0700

> For forwarding scenarios, it will be useful to allocate larger
> sendbuf. Make the necessary adjustments to permit this.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Please submit this with a proper Subject line, something like
"[PATCH 1/1] hyperv: ${DESCRIPTION}" would be fine.

As is, nobody scanning the commit headers in the tree history can
see what might be unique about this change to the hyperv driver
vs. all others, because you haven't written a proper description.
