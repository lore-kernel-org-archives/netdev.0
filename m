From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: typo, unrequired #undef and killing warning
Date: Wed, 04 Jun 2003 00:47:38 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030604.004738.26506541.davem@redhat.com>
References: <20030604.150218.69810413.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, vnuorval@tcs.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030604.150218.69810413.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Wed, 04 Jun 2003 15:02:18 +0900 (JST)

   - use braces around "&" and "|".

You mean "parentheses", braces define basic block scope in the
C language, parentheses group expressions :-)

Patch applied, thank you :-)

   
