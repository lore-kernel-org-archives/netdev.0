From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.0-test7-netx1
Date: Fri, 10 Oct 2003 01:48:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031010014822.0130ca61.davem@redhat.com>
References: <20031009155302.4f2fe835.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031009155302.4f2fe835.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Oct 2003 15:53:02 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

>     * TCP Vegas (from Dave Miller)

Please don't use a config option for this, that is why the
sysctl is there and off by default.
