From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] change netdevice to use struct device instead of struct
 class_device
Date: Wed, 05 Jul 2006 11:29:01 -0700 (PDT)
Message-ID: <20060705.112901.104047882.davem@davemloft.net>
References: <20060703231610.GA18352@kroah.com>
	<20060703.185747.74753207.davem@davemloft.net>
	<20060704223101.GA25275@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35227
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964959AbWGES2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 14:28:37 -0400
To: greg@kroah.com
In-Reply-To: <20060704223101.GA25275@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <greg@kroah.com>
Date: Tue, 4 Jul 2006 15:31:01 -0700

> Do you mind if I keep this in my tree, due to the dependancies on the
> other driver core changes?

Feel free.
