From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Consolidate multiple implementations of jiffies-msecs
 conversions.
Date: Thu, 25 Mar 2004 12:32:06 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040325123206.00b2dd1a.davem@redhat.com>
References: <Pine.LNX.4.58.0403251142110.3037@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0403251142110.3037@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 25 Mar 2004 12:17:41 -0800 (PST)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> The following patch to 2.6.5-rc2 consolidates 6 different implementations
> of msecs to jiffies and 3 different implementation of jiffies to msecs.
> All of them now use the generic msecs_to_jiffies() and jiffies_to_msecs()
> that are added to include/linux/time.h

This looks fine to me.

Jeff, I'll merge this upstream.

Thanks.
