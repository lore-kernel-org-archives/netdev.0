From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] dst allocation problem in ndisc
Date: Thu, 10 Jun 2004 22:08:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040610220802.63e92631.davem@redhat.com>
References: <OFCE4F5928.1D42CFA2-ON87256EAF.006E4EBF-07256EAF.006E5443@us.ibm.com>
	<OF9A5F0961.756FB5EE-ON87256EAF.0071FA7B-07256EAF.00720E64@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xma@us.ibm.com, mashirle@us.ibm.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <xma@us.ibm.com>
In-Reply-To: <OF9A5F0961.756FB5EE-ON87256EAF.0071FA7B-07256EAF.00720E64@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Jun 2004 14:46:20 -0600
Shirley Ma <xma@us.ibm.com> wrote:

> Change ip6_output2 to static also. This patch is against 2.6.7-rc3.

Patch applied, thanks a lot!
