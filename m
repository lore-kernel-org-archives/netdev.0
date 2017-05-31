From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] netvsc: Add #include's for csum_*
 function declarations
Date: Wed, 31 May 2017 13:59:52 -0400 (EDT)
Message-ID: <20170531.135952.1314266532351768088.davem@davemloft.net>
References: <1496166184-19805-1-git-send-email-mikelley@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, sthemmin@microsoft.com, netdev@vger.kernel.org,
 jasowang@redhat.com, linux-kernel@vger.kernel.org, marcelo.cerri@canonical.com,
 apw@canonical.com, devel@linuxdriverproject.org,
 leann.ogasawara@canonical.comi
To: mikelley@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1496166184-19805-1-git-send-email-mikelley@microsoft.com>
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

From: Michael Kelley <mikelley@microsoft.com>
Date: Tue, 30 May 2017 10:43:04 -0700

> Add direct #include statements for declarations of csum_tcpudp_magic()
> and csum_ipv6_magic(). While the needed #include's are picked up
> indirectly for the x86 architecture, they aren't on other
> architectures, resulting in compile errors.
> 
> Signed-off-by: Michael Kelley <mikelley@microsoft.com>

Applied, thank you.
