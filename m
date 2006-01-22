From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: [Bugme-new] [Bug 5936] New: Openswan tunnels + netfilter
 problem
Date: Sun, 22 Jan 2006 21:56:38 +0100
Message-ID: <43D3F186.6030206@trash.net>
References: <20060122121301.033997ca.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: webmaster@elnportal.it
In-Reply-To: <20060122121301.033997ca.akpm@osdl.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> 
> Begin forwarded message:
> 
> Date: Sun, 22 Jan 2006 12:02:22 -0800
> From: bugme-daemon@bugzilla.kernel.org
> To: bugme-new@lists.osdl.org
> Subject: [Bugme-new] [Bug 5936] New: Openswan tunnels + netfilter problem
> 
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=5936
> 
>            Summary: Openswan tunnels + netfilter problem
>     Kernel Version: 2.6.16-rc1
>             Status: NEW
>           Severity: high
>              Owner: laforge@gnumonks.org
>          Submitter: webmaster@elnportal.it
> 
> 
> Jan 22 20:23:17 router kernel: Unable to handle kernel NULL pointer 
> dereference at 000000000000009c RIP:
> Jan 22 20:23:17 router kernel: <ffffffff80345195>{xfrm4_output_finish+293}
> Jan 22 20:23:17 router kernel: PGD 35377067 PUD 0
> Jan 22 20:23:17 router kernel: Oops: 0000 [6]
> Jan 22 20:23:17 router kernel: CPU 0
> Jan 22 20:23:17 router kernel: Modules linked in: af_key deflate 
> zlib_deflate twofish serpent blowfish sha256 crypto_null ae$

Please post your iptables rules and the full list of loaded modules.
