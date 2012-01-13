From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost-net: add module alias (v2.1)
Date: Thu, 12 Jan 2012 20:07:01 -0800 (PST)
Message-ID: <20120112.200701.1473475851890804136.davem@davemloft.net>
References: <20120111091653.188b24ab@nehalam.linuxnetplumber.net>
	<CAEH94LiF_F51_avA9UWMneo1N1wY0NzJmfohpxdrkAv2WkWT5Q@mail.gmail.com>
	<20120111213038.39213819@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	kay.sievers@vrfy.org, virtualization@lists.linux-foundation.org,
	device@lanana.org
To: shemminger@vyatta.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120111213038.39213819@nehalam.linuxnetplumber.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 11 Jan 2012 21:30:38 -0800

> Subject: vhost-net: add module alias (v2.1)
> 
> By adding some module aliases, programs (or users) won't have to explicitly
> call modprobe. Vhost-net will always be available if built into the kernel.
> It does require assigning a permanent minor number for depmod to work.
> 
> Also:
>   - use C99 style initialization.
>   - add missing entry in documentation for loop-control
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

ACKs, NACKs?  What is happening here?
