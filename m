From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: fix data offset calculation when pushing frag
 options {dst1opts|auth}
Date: Thu, 10 Jul 2003 17:18:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710.171833.34738924.davem@redhat.com>
References: <20030710234449.GB30577@rei.rakuen>
	<20030711.091814.128467921.yoshfuji@linux-ipv6.org>
	<20030711.092435.64560380.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, jmorris@intercode.com.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030711.092435.64560380.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Fri, 11 Jul 2003 09:24:35 +0900 (JST)

   In article <20030711.091814.128467921.yoshfuji@linux-ipv6.org> (at Fri, 11 Jul 2003 09:18:14 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
   
   > D: fix offset of payload with extension header.
   > D: based on patch from Thomas Graf <tgraf@suug.ch>
   
   Oops, thas wrong again; please use this instead...

Applied, thanks.
