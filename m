From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [8021q] Use VLAN tag set functionality in 8021q module
 (resend)
Date: Fri, 6 Feb 2004 16:25:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206162537.7f314569.davem@redhat.com>
References: <200402051559.45159.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shmuel Hen <shmulik.hen@intel.com>
In-Reply-To: <200402051559.45159.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 5 Feb 2004 15:59:43 +0200
Shmuel Hen <shmulik.hen@intel.com> wrote:

> Make the regular/HW accelerated xmit functions in the 8021q module 
> use the new set VLAN tag functionality to reduce code duplication. 

Also applied, thanks.
