From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 IPsec support
Date: Wed, 19 Feb 2003 13:43:45 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030219.134345.124058678.davem@redhat.com>
References: <20030219134850.5f203ea7.Kazunori.Miyazawa@jp.yokogawa.com>
	<20030218.233301.98333082.davem@redhat.com>
	<m3el645hv3.wl@karaba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kunihiro@ipinfusion.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mk@karaba.org
In-Reply-To: <m3el645hv3.wl@karaba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Mitsuru KANDA / 神田 充 <mk@karaba.org>
   Date: Thu, 20 Feb 2003 01:56:48 +0900

   I attached xfrm_user.c patch below.
   
Thank you, I will apply this.
   
   Just FYI, 
   the IPv6 part of this patch depends xfrm6_state_lookup().

It is ok, it exists in 2.5.x tree already.  But thank you
for this reminder.
