From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/ethernet/3com: Drop EISA dependency from
 VORTEX
Date: Thu, 13 Jun 2013 01:34:17 -0700 (PDT)
Message-ID: <20130613.013417.1870836967244200694.davem@davemloft.net>
References: <CAG2jQ8hACp_iGEXR7rXKR3sydK4O=y0paeh1FFgH2UisxWVxVA@mail.gmail.com>
	<51B78594.5050903@windriver.com>
	<51B78C82.7020709@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, markos.chandras@gmail.com,
	markos.chandras@imgtec.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51B78C82.7020709@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 12 Jun 2013 00:45:54 +0400

>    We have the user of 3Com EISA cards on this list and I've fixed EISA
> specific bug in this driver not long ago.

Then I obviously must reject this patch.
