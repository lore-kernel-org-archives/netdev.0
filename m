From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Default Route Support on Router
Date: Sat, 28 Sep 2002 23:19:15 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020928.231915.113302934.davem@redhat.com>
References: <20020928.172306.102654240.davem@redhat.com>
	<200209290209.GAA12099@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.ORG, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200209290209.GAA12099@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Sun, 29 Sep 2002 06:09:52 +0400 (MSD)

   > can we just detroy it? :-)
   
   Must, I think.
   
   Though with your current mood about per-flow cache the file
   could deserve... mmm... post-mortem examination. :-)

Oh I see... perhaps you imply I should destroy CONFIG_RT6_POLICY
remnants as well? :-)

I think we should, the less clutter when hacking these things
the better.
