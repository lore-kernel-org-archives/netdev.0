From: "David S. Miller" <davem@redhat.com>
Subject: Re: sysctl variable to force IGMP version [PATCH]
Date: Thu, 29 Jan 2004 14:36:39 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040129143639.768d2f5f.davem@redhat.com>
References: <OFE8AE1A1B.D2C2DA34-ON88256E2A.0019F0C1@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFE8AE1A1B.D2C2DA34-ON88256E2A.0019F0C1@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 28 Jan 2004 20:51:32 -0800
David Stevens <dlstevens@us.ibm.com> wrote:

>       As it is, it doesn't hurt anything if you set it to "47"-- it'll use
> IGMPv1 if it's set to "1", IGMPv2 if it's set to "2" and IGMPv3 (default)
> for all other values.

Ok, the existing patch is fine then.  Can you cook up a 2.4.x one too?

Thanks David.
