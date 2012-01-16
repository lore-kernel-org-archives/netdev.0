From: Alan Cox <alan@linux.intel.com>
Subject: Re: [PATCH] vhost-net: add module alias (v2.1)
Date: Mon, 16 Jan 2012 23:34:19 +0000
Message-ID: <20120116233419.34cda70f@bob.linux.org.uk>
References: <20120111091653.188b24ab@nehalam.linuxnetplumber.net>
	<CAEH94LiF_F51_avA9UWMneo1N1wY0NzJmfohpxdrkAv2WkWT5Q@mail.gmail.com>
	<20120111213038.39213819@nehalam.linuxnetplumber.net>
	<20120112.200701.1473475851890804136.davem@davemloft.net>
	<20120115124236.GA31012@redhat.com>
	<20120116122645.2257b40b@bob.linux.org.uk>
	<20120116075236.110cc4b4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, kay.sievers@vrfy.org,
	virtualization@lists.linux-foundation.org, device@lanana.org,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120116075236.110cc4b4@nehalam.linuxnetplumber.net>
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

> Also:
>   - use C99 style initialization.
>   - add missing entry in documentation for loop-control
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

For the device allocation

Acked-by: Alan Cox <devices@lanana.org>
