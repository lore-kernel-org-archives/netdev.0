From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 0/8] Non-promisc bidge ports support
Date: Thu, 15 May 2014 12:09:06 -0400
Message-ID: <5374E6A2.7000102@redhat.com>
References: <1400080168-16625-1-git-send-email-vyasevic@redhat.com>
	<20140514.152953.1992805646844184373.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	jhs@mojatatu.com, john.r.fastabend@intel.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140514.152953.1992805646844184373.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 05/14/2014 03:29 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Wed, 14 May 2014 11:09:20 -0400
> 
>> This series adds functionality to the bridge device to enable
>> operations without setting all ports to promiscuous mode.
> 
> I'm prepared to apply this, please address the minor stylistic
> feedback you've received and resubmit.
> 
> Also, what does:
> 
> ====================
> Conflicts:
> 	net/bridge/br_if.c
> 	net/bridge/br_private.h
> ====================
> 
> exactly mean in patch #7?
> 
> Thanks.
>

Looks like left-overs after a few rebases...  I'll remove.

Will resubmit shortly with corrections.

Thanks
-vlad
