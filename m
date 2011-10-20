From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: Clean up set_skb_frag()
Date: Thu, 20 Oct 2011 04:54:11 -0400 (EDT)
Message-ID: <20111020.045411.1875503503183541494.davem@davemloft.net>
References: <20111020081727.509.83122.sendpatchset@krkumar2.in.ibm.com>
	<1319100362.3781.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: krkumar2@in.ibm.com, rusty@rustcorp.com.au, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319100362.3781.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2011 10:46:02 +0200

> Le jeudi 20 octobre 2011 =E0 13:47 +0530, Krishna Kumar a =E9crit :
>> Remove manual initialization in set_skb_frag, and instead
>> use __skb_fill_page_desc() to do the same. Patch tested
>> on net-next.
>>=20
>> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
=2E..
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
