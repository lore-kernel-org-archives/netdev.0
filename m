From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [NET] use fl6_{src,dst} etc.
Date: Mon, 14 Apr 2003 10:48:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030414.104826.104550461.davem@redhat.com>
References: <20030415.023158.36869337.yoshfuji@linux-ipv6.org>
	<20030414.103143.64788453.davem@redhat.com>
	<20030415.025206.31321166.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030415.025206.31321166.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Tue, 15 Apr 2003 02:52:06 +0900 (JST)
   
   fl_ip_{sport,dport}?
   (fl_port_{sport,dport} sounds like "white horse is white" to me.)

Ok, fl_ip_* is fine. :-)
