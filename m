From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER 00/10]: Netfilter IPsec support
Date: Sat, 07 Jan 2006 03:29:44 +0100
Message-ID: <43BF2798.2030906@trash.net>
References: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
	<20060106.202140.97921155.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	usagi-core@linux-ipv6.org, davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060106.202140.97921155.yoshfuji@linux-ipv6.org>
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

YOSHIFUJI Hideaki / $B5HF#1QL@ wrote:
> In article <20060107010855.8712.68786.sendpatchset@localhost.localdomain> (at Sat,  7 Jan 2006 02:09:30 +0100 (MET)), Patrick McHardy <kaber@trash.net> says:
> 
> 
>>following are the remaining patches for netfilter IPsec support.
>>They are missing the common-case optimization for inner transport mode
>>SAs on the input path, but since its just an optimization, I think
>>it can also be done later. One note: unfortunately I had to increase
> 
> 
> I definitely want to do it before 2.6.16.

That shouldn't be a problem, its not hard, but I think it might get
a bit ugly.

> Anyway, we'll test this series of patches.

Thanks.
