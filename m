From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] IPv4 Netfilter hook priorities for SELinux
Date: Tue, 6 Jan 2004 21:36:42 -0800
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040106213642.3b30f4bc.davem@redhat.com>
References: <20040106191311.GH934@obroa-skai.de.gnumonks.org>
	<Xine.LNX.4.44.0401061503180.8482-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, sds@epoch.ncsc.mil
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0401061503180.8482-100000@thoron.boston.redhat.com>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Tue, 6 Jan 2004 15:05:10 -0500 (EST)
James Morris <jmorris@redhat.com> wrote:

> Ok, here is the patch with support for IPv4 and IPv6.  I've not added 
> anything for ARP yet as SELinux does not have any ARP controls at this 
> stage (and probably won't in the near future).
> 
> Please apply.

Applied, thanks guys.
