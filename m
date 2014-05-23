From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Add hash value into RNDIS Per-packet info
Date: Fri, 23 May 2014 14:50:01 -0400 (EDT)
Message-ID: <20140523.145001.2140056621716323006.davem@davemloft.net>
References: <1400702139-29280-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1400702139-29280-1-git-send-email-haiyangz@microsoft.com>
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
Date: Wed, 21 May 2014 12:55:39 -0700

> It passes the hash value as the RNDIS Per-packet info to the Hyper-V host,
> so that the send completion notices can be spread across multiple channels.
> MS-TFS: 140273
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied, but please craft your Subject lines correctly in the future.

You did not specify a subsystem prefix, which in this case should
have been something like "hyperv: "

Otherwise people scanning the commit log headers have no idea where
your changes might be taking place.

I fixed it up this time for you.

Thanks.
