From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] Delete unused fec_8xx net driver
Date: Tue, 13 May 2008 10:12:25 -0500
Message-ID: <06153BF4-5E1B-44D7-B7DC-D909F2DC8A58@kernel.crashing.org>
References: <Pine.LNX.4.64.0805021320360.24806@monty.am.freescale.net>
	<48208790.5090508@pobox.com>
	<20080508172519.GA12162@gate.crashing.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jengelh@medozas.de, linuxppc-dev@ozlabs.org,
	scottwood@freescale.com, Jeff Garzik <jgarzik@pobox.com>
To: Vitaly Bordug <vitb@gate.crashing.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20080508172519.GA12162@gate.crashing.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On May 8, 2008, at 12:25 PM, Vitaly Bordug wrote:

> On Tue, May 06, 2008 at 12:30:08PM -0400, Jeff Garzik wrote:
>> Becky Bruce wrote:
>>> This driver has been superseded by fs_enet and is no longer in use.
>>>
>>> Signed-off-by: Becky Bruce <becky.bruce@freescale.com>
>>
>> I cannot make an informed judgement on this.
>>
>> ACK, and pass through platform tree, if all platform peeps are happy.
>
> I'll move thins along.

I've applied this to my tree and will push via powerpc.git.

- k
