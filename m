From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [NET 2.4] split arp_send into arp_create and arp_xmit
Date: Thu, 19 Feb 2004 10:17:33 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040219101733.03140b8f.davem@redhat.com>
References: <200402191211.07879.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Shmuel Hen <shmulik.hen@intel.com>
In-Reply-To: <200402191211.07879.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Feb 2004 12:11:05 +0200
Shmuel Hen <shmulik.hen@intel.com> wrote:

> Summary:
> Enable intermediate network drivers like bonding to create an ARP 
> packet and modify it to their needs before sending it, while avoiding 
> code duplication. It does not affect any other place in the kernel 
> that uses arp_send. 

Applied.  Thanks for following up on this Shmuel.
