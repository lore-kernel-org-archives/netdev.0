From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] make sendmsg return EDESTADDRREQ if socket is not
 connected and daddr was not specified
Date: Thu, 10 Jul 2003 17:29:23 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710.172923.27804984.davem@redhat.com>
References: <20030710233223.GA30577@rei.rakuen>
	<20030711.093546.12708723.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030711.093546.12708723.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Fri, 11 Jul 2003 09:35:46 +0900 (JST)
   
   I aggeed on this, however we may want to do for whole tree at same time.
   How do you think, folks?

Sure, just send more patches relative to this one :-)
