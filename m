From: Andrew Morton <akpm@osdl.org>
Subject: dm-crypt changes in git-net tree
Date: Mon, 4 Dec 2006 22:59:07 -0800
Message-ID: <20061204225907.6b486e57.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:37099 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937460AbWLEG7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 01:59:46 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Rik Snel <rsnel@cube.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On x86_64:

drivers/md/dm-crypt.c: In function 'crypt_iv_benbi_ctr':
drivers/md/dm-crypt.c:235: warning: cast to pointer from integer of different size
drivers/md/dm-crypt.c: In function 'crypt_iv_benbi_gen':
drivers/md/dm-crypt.c:248: warning: cast from pointer to integer of different size
drivers/md/dm-crypt.c:248: warning: cast from pointer to integer of different size
drivers/md/dm-crypt.c:248: warning: cast from pointer to integer of different size
