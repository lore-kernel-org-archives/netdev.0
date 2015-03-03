From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] net/atm/signaling.c: remove
 WAIT_FOR_DEMON code
Date: Tue, 03 Mar 2015 14:25:15 -0500 (EST)
Message-ID: <20150303.142515.177137512284659970.davem@davemloft.net>
References: <1425407926-15917-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, chas@cmf.nrl.navy.mil,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425407926-15917-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Tue,  3 Mar 2015 19:38:46 +0100

> WAIT_FOR_DEMON code is directly undefined at the beginning
> of signaling.c since initial git version and thus never compiled.
> This also removes buggy current->state direct access.
> 
> Suggested-by: Chas Williams <chas@cmf.nrl.navy.mil>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied, thanks.
