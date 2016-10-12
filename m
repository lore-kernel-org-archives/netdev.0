From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] drivers: net: xgene: fix: Use GPIO to get
 link status
Date: Wed, 12 Oct 2016 01:54:22 -0400 (EDT)
Message-ID: <20161012.015422.1466108933958598182.davem@davemloft.net>
References: <1475789758-5196-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patches@apm.com, arnd@arndb.de,
 linux-arm-kernel@lists.infradead.org, qnguyen@apm.com
To: isubramanian@apm.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1475789758-5196-1-git-send-email-isubramanian@apm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Thu,  6 Oct 2016 14:35:56 -0700

> Since the link value reported by the link status register is not
> reliable if no SPF module inserted, this patchset fixes the issue by
> using GPIO to determine the link status when no module inserted.
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Signed-off-by: Quan Nguyen <qnguyen@apm.com>

Series applied, thanks.
