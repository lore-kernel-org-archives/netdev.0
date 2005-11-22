From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 02/10]: [NETFILTER]: Defer fragmentation in ip_output
 when connection tracking is used
Date: Tue, 22 Nov 2005 09:17:29 +0100
Message-ID: <4382D419.6070705@trash.net>
References: <43740DB5.9070206@trash.net>
	<20051115104425.GA31719@gondor.apana.org.au>
	<437BEAC8.40904@trash.net>
	<20051122075904.GL31478@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20051122075904.GL31478@sunbeam.de.gnumonks.org>
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

Harald Welte wrote:
> On Thu, Nov 17, 2005 at 03:28:24AM +0100, Patrick McHardy wrote:
> 
> 
>>- CLASSIFY fragments differently
>>- MARK fragments differently
>>- DSCP/ECN/TOS mark fragments differently
>>- Change TTLs of fragments to differently values
> 
> [...]
> 
>>I've CCed Harald for his opinion in case I missed something.
> 
> 
> I don't think you've missed something.  I agree that the features you
> pointed out seem to be useful and/or important.

I hope you meant to write "don't seem to be"? :)
