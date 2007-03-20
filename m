From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NAT and requests to unrouted targets
Date: Tue, 20 Mar 2007 13:34:31 +0100
Message-ID: <45FFD4D7.30505@trash.net>
References: <000001c766d8$66f1cc00$1a04010a@V505CP>
	<45F90905.4000408@trash.net>
	<001101c76711$cf7dc6a0$1a04010a@V505CP>
	<45FEB411.5050004@trash.net>
	<000f01c76ae6$c5bdc880$1a04010a@V505CP>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	'Netfilter Development Mailinglist' <netfilter-devel@lists.netfilter.org>
To: Martin Schiller <mschiller@tdt.de>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
In-Reply-To: <000f01c76ae6$c5bdc880$1a04010a@V505CP>
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

Martin Schiller wrote:
> On Monday, March 19, 2007 5:02 PM, Patrick McHardy wrote:
> 
>>Could you try this patch (against current -git) with CONFIG_XFRM
>>enabled please? 
> 
> 
> I've tried it and the ping is still working now with enabled CONFIG_XFRM.
> 
> Thanks for the patch.


Thanks for testing, I'll push it upstream soon.
