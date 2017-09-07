From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dt-binding: phy: don't confuse with Ethernet phy
 properties
Date: Wed, 06 Sep 2017 21:14:08 -0700 (PDT)
Message-ID: <20170906.211408.405234401414250787.davem@davemloft.net>
References: <0a90f4b3cc903af6f82002e502deba67f374c602.1504449136.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kishon@ti.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: baruch@tkos.co.il
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0a90f4b3cc903af6f82002e502deba67f374c602.1504449136.git.baruch@tkos.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Siach <baruch@tkos.co.il>
Date: Sun,  3 Sep 2017 17:32:16 +0300

> The generic PHY 'phys' property sometime appears in the same node with
> the Ethernet PHY 'phy' or 'phy-handle' properties. Add a warning in
> phy-bindings.txt to reduce confusion.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

Applied.
