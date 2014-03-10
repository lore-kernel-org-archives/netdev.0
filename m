From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hyperv: Change the receive buffer size for
 legacy hosts
Date: Mon, 10 Mar 2014 16:16:53 -0400 (EDT)
Message-ID: <20140310.161653.166084311676254585.davem@davemloft.net>
References: <1394406659-22493-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1394406659-22493-1-git-send-email-haiyangz@microsoft.com>
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

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Sun,  9 Mar 2014 16:10:59 -0700

> Due to a bug in the Hyper-V host verion 2008R2, we need to use a slightly smaller
> receive buffer size, otherwise the buffer will not be accepted by the legacy hosts.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied.
