From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: ipv6 UDP MSG_MORE oops fix
Date: Fri, 08 Aug 2003 17:08:39 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030808.170839.90822982.yoshfuji@linux-ipv6.org>
References: <20030807223421.70497d61.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030807223421.70497d61.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030807223421.70497d61.davem@redhat.com> (at Thu, 7 Aug 2003 22:34:21 -0700), "David S. Miller" <davem@redhat.com> says:

> Yoshfuji-san, I found the MSG_MORE udp bug.

Yes, thanks. This is what I told you before.
I'm going to test if problems go away with this patch.

--yoshfuji
