From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 3/6][8021q][2.4] Use VLAN tag set functionality in 8021q
 module
Date: Thu, 22 Jan 2004 10:06:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040122100632.05dd4f8b.davem@redhat.com>
References: <200401221757.21240.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Shmuel Hen <shmulik.hen@intel.com>
In-Reply-To: <200401221757.21240.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 22 Jan 2004 17:57:19 +0200
Shmuel Hen <shmulik.hen@intel.com> wrote:

> Make the regular/HW accelerated xmit functions in the 8021q module
> use the new set VLAN tag functionality to reduce code duplication.

I'm fine with this and the ARP change, I am pretty sure.

But we have way too much stuff pending for the next 2.6.x release,
so I'm going to defer adding these changes until Linus puts something
final out.

Please resend these two changes after he does a release.

Thanks.
