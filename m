From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]dump interface IPv6 multicast/anycast addresses through
 netlink
Date: Sat, 3 Apr 2004 14:45:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040403144540.7f201bc1.davem@redhat.com>
References: <OF8F6A9EBE.82E160C6-ON87256E69.001BB337-88256E69.001D33A3@us.ibm.com>
	<200404011028.13048.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xma@us.ibm.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
        yoshfuji@cerberus.hongo.wide.ad.jp
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <mashirle@us.ibm.com>
In-Reply-To: <200404011028.13048.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 1 Apr 2004 10:28:12 -0800
Shirley Ma <mashirle@us.ibm.com> wrote:

> Here is the new patch. It has been tested against linux 2.6.4 kernel.

I'm Ok with this patch and I believe Yoshfuji et al. are too.

But this patch will not apply cleanly to current 2.6.x sources,
please rediff.

Thanks.
