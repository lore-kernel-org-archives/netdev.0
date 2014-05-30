From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] emac: aggregation of v1-2 PLB errors for IER
 register
Date: Fri, 30 May 2014 16:31:07 -0700 (PDT)
Message-ID: <20140530.163107.599356297485033501.davem@davemloft.net>
References: <1401129279.24099.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, alistair@popple.id.au,
	robh+dt@kernel.org, grant.likely@linaro.org
To: ivan@ru.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401129279.24099.23.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Mikhaylov <ivan@ru.ibm.com>
Date: Mon, 26 May 2014 22:34:39 +0400

> Aggreagation of version 1-2 because of version 1 can hit
> PLB errors too. If it's not set so we missing events for PLB bits
> and driver can't process those interrupts.
> 
> Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>

Applied.
