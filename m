From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NET: bna, fix lock imbalance
Date: Mon, 06 Sep 2010 18:29:47 -0700 (PDT)
Message-ID: <20100906.182947.258128485.davem@davemloft.net>
References: <1283602121-11443-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	netdev@vger.kernel.org, ddutt@brocade.com, rmody@brocade.com
To: jslaby@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283602121-11443-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Sat,  4 Sep 2010 14:08:41 +0200

> bnad_set_rx_mode omit to unlock bna_lock on one fail path. Fix that.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>

Applied.
