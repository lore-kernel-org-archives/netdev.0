From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [8021q] Export VLAN tag get/set functionality (resend)
Date: Fri, 6 Feb 2004 16:25:20 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206162520.308c523d.davem@redhat.com>
References: <200402051559.27597.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shmuel Hen <shmulik.hen@intel.com>
In-Reply-To: <200402051559.27597.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 5 Feb 2004 15:59:22 +0200
Shmuel Hen <shmulik.hen@intel.com> wrote:

> Enable intermediate network drivers like bonding to get or set a 
> VLAN tag in an skb without a need to know about how tagging is done 
> according to a network adapter's capabilities. 
> 
> Tested for patch application and compilation against linux-2.6.2.

Applied.
