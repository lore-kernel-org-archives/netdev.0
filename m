From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Prefix List patch against 2.5.70
Date: Fri, 30 May 2003 23:32:57 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030530.233257.21920899.davem@redhat.com>
References: <3ED80230.2030508@us.ibm.com>
	<20030531.110249.12960077.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030531.110249.12960077.yoshfuji@linux-ipv6.org>
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Sat, 31 May 2003 11:02:49 +0900 (JST)
   
   Again, what I proposed was to store prefix information on fib with 
   some flags to represent advertised by routers and give user-space 
   the RA information using new rtattr (RTA_RA6INFO or something like that).

This sounds very reasonable.
