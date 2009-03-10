From: David Miller <davem@davemloft.net>
Subject: Re: net_device_ops support in bridging and fec_mpc52xx.c
Date: Tue, 10 Mar 2009 10:19:59 -0700 (PDT)
Message-ID: <20090310.101959.142777275.davem@davemloft.net>
References: <20090218.134852.118040610.davem@davemloft.net>
	<ae4f76fd0902190145r7ed5fadbwfca18c97dbfc9ed1@mail.gmail.com>
	<fa686aa40903101013j2324e8acw18830c930e12ae46@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, henk.stegeman@gmail.com,
	bridge@osdl.org, jgarzik@pobox.com
To: grant.likely@secretlab.ca
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <fa686aa40903101013j2324e8acw18830c930e12ae46@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Grant Likely <grant.likely@secretlab.ca>
Date: Tue, 10 Mar 2009 11:13:02 -0600

> Hi Henk,
> 
> Acked-by: Grant Likely <grant.likely@secretlab.ca>
 ...
> Jeff, after Henk provides his s-o-b line, do you want to pick it up,
> or should I merge it through my mpc52xx powerpc tree (via benh).

Send it to netdev, CC:'d to me, Jeff hasn't been handling networking
driver changes for a while now.
