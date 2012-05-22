From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESENT] xen: do not disable netfront in dom0
Date: Tue, 22 May 2012 16:50:47 -0400 (EDT)
Message-ID: <20120522.165047.1026251950879022093.davem@davemloft.net>
References: <20120522194319.GA2691@phenom.dumpdata.com>
	<20120522204742.29E8A626@duch.mimuw.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jeremy@goop.org, Ian.Campbell@citrix.com, konrad.wilk@oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, xen-devel@lists.xen.org
To: marmarek@invisiblethingslab.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120522204742.29E8A626@duch.mimuw.edu.pl>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Marek Marczykowski <marmarek@invisiblethingslab.com>
Date: Sun, 20 May 2012 13:45:10 +0200

> Netfront driver can be also useful in dom0, eg when all NICs are assigned to
> some domU (aka driver domain). Then using netback in domU and netfront in dom0
> is the only way to get network access in dom0.
> 
> Signed-off-by: Marek Marczykowski <marmarek@invisiblethingslab.com>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>
> Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Applied, thanks.
