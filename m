From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net, V1 0/3] Fix issues with Heper-V network offload code
Date: Fri, 11 Apr 2014 15:18:20 -0400 (EDT)
Message-ID: <20140411.151820.2244532449368168368.davem@davemloft.net>
References: <1397080810-17953-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1397080810-17953-1-git-send-email-kys@microsoft.com>
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
Date: Wed,  9 Apr 2014 15:00:10 -0700

> WS2008 R2 does not support udp checksum offload. Furthermore, ws2012 and
> ws2012 r2 have issues offloading udp checksum from Linux guests.
> This patch-set addresses these issues as well as other bug fixes.
> Please apply.
> 
> In this version, I have addressed the comment from David Miller with reagards
> to COWing the skb prior to modifying the header (patch 3/3).

This looks a lot better, series applied, thanks.
