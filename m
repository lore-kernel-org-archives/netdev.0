From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Default Route Support on Router
Date: Sat, 28 Sep 2002 17:23:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020928.172306.102654240.davem@redhat.com>
References: <20020928.151959.131438421.yoshfuji@linux-ipv6.org>
	<200209282047.AAA03890@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.ORG, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200209282047.AAA03890@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Sun, 29 Sep 2002 00:47:05 +0400 (MSD)

   One question, what is this chunk for?

This reminds me, nothing is aparently going to make use
of net/ipv6/ip6_fw.c, it sits unused and untouched for
years, can we just detroy it? :-)
