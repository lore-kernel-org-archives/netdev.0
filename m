From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPSEC: typo in xfrm_sk_clone_policy()
Date: Tue, 11 Mar 2003 23:38:43 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030311.233843.97559124.davem@redhat.com>
References: <20030312.161749.123173528.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030312.161749.123173528.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Wed, 12 Mar 2003 16:17:49 +0900 (JST)

   I think following patch fixes a typo in xfrm_sk_clone_policy()
   which results in infinite loop if sk->policy[0] or sk->policy[1] is true.
   
   Patch is for 2.5.64.

Patch applied, thank you.
