From: "David S. Miller" <davem@redhat.com>
Subject: Re: small netfilter cleanup
Date: Sun, 6 Jun 2004 20:15:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040606201527.15840046.davem@redhat.com>
References: <1086434538.1590.16.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@znyx.com
In-Reply-To: <1086434538.1590.16.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 05 Jun 2004 07:22:19 -0400
Jamal Hadi Salim <hadi@znyx.com> wrote:

> I have been sitting on these patches for sometime now.
> Harald, we did discuss this back when.
> Attached patches for 2.4.26 and 2.6.6; both should patch
> cleanly against pre 2.4.27 and 2.6.7

All applied, thanks guys.

Jamal could you do me a huge favor and "-p1" root your
patches?  Ie. instead of:

--- /usr/src/266/include/linux/netfilter.h	2004-05-09 22:32:37.000000000 -0400
+++ /usr/src/266-mod/include/linux/netfilter.h	2004-06-04 10:21:20.000000000 -0400

make it instead be:

--- 266/include/linux/netfilter.h	2004-05-09 22:32:37.000000000 -0400
+++ 266-mod/include/linux/netfilter.h	2004-06-04 10:21:20.000000000 -0400

Thanks.
