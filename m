From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [NETFILTER 00/10]: Netfilter IPsec support
Date: Fri, 06 Jan 2006 20:21:40 -0600 (CST)
Message-ID: <20060106.202140.97921155.yoshfuji@linux-ipv6.org>
References: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	usagi-core@linux-ipv6.org, davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
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

In article <20060107010855.8712.68786.sendpatchset@localhost.localdomain> (at Sat,  7 Jan 2006 02:09:30 +0100 (MET)), Patrick McHardy <kaber@trash.net> says:

> following are the remaining patches for netfilter IPsec support.
> They are missing the common-case optimization for inner transport mode
> SAs on the input path, but since its just an optimization, I think
> it can also be done later. One note: unfortunately I had to increase

I definitely want to do it before 2.6.16.
Anyway, we'll test this series of patches.  Thank you.

--yoshfuji
