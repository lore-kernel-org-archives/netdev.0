From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH/RFC] IPV6: Remember Manage/OtherConfig flags
Date: Thu, 12 Jun 2003 00:38:00 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030612.003800.71577627.davem@redhat.com>
References: <20030611.162849.52863261.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, krkumar@us.ibm.com
Return-path: <linux-net-owner@vger.kernel.org>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030611.162849.52863261.yoshfuji@linux-ipv6.org>
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Wed, 11 Jun 2003 16:28:49 +0900 (JST)
   
   Managed flag and OtherConfig flag are maintained on a per-interface 
   basis (RFC2462 5.2).
   
   So, let's store them in inet6_dev{}.
   
Let's put this in when something actually uses it ok?
