From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] add SCTP to xfrm_flowi_{sport,dport}()
Date: Tue, 24 Aug 2004 11:48:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824114845.497eadb2.davem@redhat.com>
References: <20040824.230409.21312009.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040824.230409.21312009.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Aug 2004 23:04:09 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> (I'm not sure if ipsec is fully supported for sctp, but anyway,)

It should work.  It should have xfrm checks in sctp input path
and everything.  Well, at least I cannot think of reason why it
should not work :)

> I should not have made regression here.

Patch applied, thank you.
