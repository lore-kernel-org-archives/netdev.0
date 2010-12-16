From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix bug in Ethernet Channel Bonding Driver
Date: Thu, 16 Dec 2010 12:24:40 -0800 (PST)
Message-ID: <20101216.122440.115943226.davem@davemloft.net>
References: <AANLkTiksuf0ZDWyjH6ec9rSRoG+5ZdakA-Tha9MXLvy+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dhillf@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTiksuf0ZDWyjH6ec9rSRoG+5ZdakA-Tha9MXLvy+@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hillf Danton <dhillf@gmail.com>
Date: Sat, 11 Dec 2010 12:54:11 +0800

> The returned slave is incorrect, if the net device under check is not
> charged yet by the master.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Applied, thank you.
