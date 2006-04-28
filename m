From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netem: fix loss
Date: Fri, 28 Apr 2006 12:12:00 -0700 (PDT)
Message-ID: <20060428.121200.130333581.davem@davemloft.net>
References: <20060428102240.59ba2a7a@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gnychis@cmu.edu, netem@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20365
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751802AbWD1TMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 15:12:15 -0400
To: shemminger@osdl.org
In-Reply-To: <20060428102240.59ba2a7a@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 28 Apr 2006 10:22:40 -0700

> The following one line fix is needed to make loss function of
> netem work right when doing loss on the local host.
> Otherwise, higher layers just recover.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
