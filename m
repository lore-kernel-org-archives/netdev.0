From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Source Address of MLD Message
Date: Fri, 18 Oct 2002 18:09:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021018.180933.80085592.davem@redhat.com>
References: <20021018.125215.922751890.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20021018.125215.922751890.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Fri, 18 Oct 2002 12:52:15 +0900 (JST)

   draft-ietf-magma-mld-source-02.txt clarifies that the source address of
   MLD Report / Done Message MUST be unspecified address when a link-local
   address is not available.  This patch follows this clarification.
   
   This patch is against 2.4.20-pre10.

Patch is applied, thanks.
