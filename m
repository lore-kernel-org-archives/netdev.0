From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Fri, 27 Sep 2002 20:36:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020927.203606.32735488.davem@redhat.com>
References: <20020927.195507.87349906.davem@redhat.com>
	<200209280338.HAA02810@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200209280338.HAA02810@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Sat, 28 Sep 2002 07:38:09 +0400 (MSD)

   Now I see retransmission of practicllay the same patch, which was deferred
   for improvement that time.

Ok, Yoshi please work Alexey to put source address selection into the
right place and remove ipv6_get_saddr().

Alexey, I still am not clear, this belongs in the output routing logic
right?  You dance in circles talking about this patch, that patch,
but what I cannot decode this into an answer to question of where
source address selection belongs.
