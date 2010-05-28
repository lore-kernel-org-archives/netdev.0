From: ratheesh k <ratheesh.ksz@gmail.com>
Subject: fn_trie_lookup and fn_hash_lookup
Date: Fri, 28 May 2010 08:53:11 +0530
Message-ID: <AANLkTikmIzPaOKdlXtCwosfJXzaKY1vxib_MdqI0vN_5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi ,

I was looking into 2.6.18 kernel . I can see two functions
fn_trie_lookup , fn_hash_lookup

ipv4/fib_trie.c:	tb->tb_lookup = fn_trie_lookup;
ipv4/fib_hash.c:	tb->tb_lookup = fn_hash_lookup;

What is the differnce between these two functions ?


Thanks,
Ratheesh
