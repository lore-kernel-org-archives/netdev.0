From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Drivers: net-next: hyperv: Adjust the size of
 sendbuf region to support ws2008r2
Date: Wed, 06 Aug 2014 13:52:32 -0700 (PDT)
Message-ID: <20140806.135232.339777611093154433.davem@davemloft.net>
References: <1407348660-6844-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1407348660-6844-1-git-send-email-kys@microsoft.com>
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
Date: Wed,  6 Aug 2014 11:11:00 -0700

> WS2008R2 is a supported platform and it turns out that the maximum sendbuf
> size that ws2008R2 can support is only 15MB. Make the necessary
> adjustment.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, thanks.
