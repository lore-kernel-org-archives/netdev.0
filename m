From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] remove historic entries in Documentation/Changes
Date: Tue, 28 Oct 2003 08:18:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031028081816.10d1ebce.davem@redhat.com>
References: <20031029.012202.105420248.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20031029.012202.105420248.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Oct 2003 01:22:02 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> It seems that these entries are out-of-date;
> "bk annotate" tells these lines are very old.
> 
> Please ensure if it is correct.

Well, just removing all references to iproute2 would not
be correct, we should mention the current location one
can obtain the latest iproute2 sources from.

Actually, all of these random changes are beginning to become cleanup
in nature and therefore not the kind of changes Linus wants going into
the tree right now.

Can you make these Kconfig and documentation fixes at some later time?
Thank you.
