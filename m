From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 0/3] Series short description
Date: Thu, 2 Apr 2009 07:41:23 -0600
Message-ID: <fa686aa40904020641k4db9e66dh4f80b5b32f68455d@mail.gmail.com>
References: <20090401060117.8641.32252.stgit@localhost.localdomain>
	<20090402.005715.02030593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090402.005715.02030593.davem@davemloft.net>
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

On Thu, Apr 2, 2009 at 1:57 AM, David Miller <davem@davemloft.net> wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
> Date: Wed, 01 Apr 2009 00:16:46 -0600
>
>> Here are the fec_mpc52xx patches which should be picked up for 2.6.29.
>> Patch #1 fixes a dma related BUG_ON() discovered after the merge window
>> opened. =A0#2 & #3 were original a single patch posted prior to the merge
>> window, but not having a s-o-b line from the original author held them u=
p.
>> In the end I rewrote it from scratch as two patches just so I can get
>> them merged. =A0#2 makes the driver use net_device_ops, and #3 fixes a N=
ULL
>> dereference.
>>
>> I've tested these patches on several MPC5200 platforms.
>
> All applied, thanks Grant.

Thanks David!

g.

-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
