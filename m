From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-03-13
Date: Tue, 13 Mar 2012 15:58:02 -0700 (PDT)
Message-ID: <20120313.155802.165343340749302246.davem@davemloft.net>
References: <20120313192119.GC5837@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120313192119.GC5837@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 13 Mar 2012 15:21:20 -0400

> Stanislaw has given us two late-breaking fixes intended for 3.3.  One
> avoids a NULL pointer dereference in iwl3945, and the other corrects a
> locking issue in the rt2x00 driver that can lead to random traffic
> stalls.
> 
> Please let me know if there are problems!

Pulled, thanks.
