From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] convert ipmr to seq_file.
Date: Thu, 25 Sep 2003 20:48:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925204804.00e457f1.davem@redhat.com>
References: <20030925142351.18cda5dd.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030925142351.18cda5dd.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 25 Sep 2003 14:23:51 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Convert /proc/ip_mr_cache and /proc/ip_mr_vif to use seq_file.
> Tested with 2.6.0-test5 latest.

Looks good, applied.
