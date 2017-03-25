From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH 0/2] net: netfilters: Remove typedef
Date: Sat, 25 Mar 2017 17:57:54 +0530
Message-ID: <20170325122756.8743-1-arushisinghal19971997@gmail.com>
Cc: pablo@netfilter.org, davem@davemloft.net,
        outreachy-kernel@googlegroups.com, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, gregkh@linuxfoundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Arushi Singhal <arushisinghal19971997@gmail.com>
To: kadlec@blackhole.kfki.hu
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove typedef from struct.

Arushi Singhal (2):
  net: netfilter: Remove typedef from "typedef struct field_t"
  net: netfilter: Remove typedef from "typedef struct bitstr_t"

 net/netfilter/nf_conntrack_h323_asn1.c | 98 +++++++++++++++++-----------------
 1 file changed, 49 insertions(+), 49 deletions(-)

-- 
This is my contribition to outreachy project nftables.

2.11.0
