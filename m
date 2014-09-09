From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethernet: ti: remove unwanted THIS_MODULE
 macro
Date: Tue, 09 Sep 2014 11:59:28 -0700 (PDT)
Message-ID: <20140909.115928.2263127447345685807.davem@davemloft.net>
References: <1410148699-3724-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, balbi@ti.com, mugunthanvnm@ti.com,
	linux@rainbow-software.org, linux-kernel@vger.kernel.org,
	varkab@cdac.in
To: varkabhadram@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410148699-3724-1-git-send-email-varkab@cdac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varka Bhadram <varkabhadram@gmail.com>
Date: Mon,  8 Sep 2014 09:28:19 +0530

> It removes the owner field updation of driver structure.
> It will be automatically updated by module_platform_driver()
> 
> Signed-off-by: Varka Bhadram <varkab@cdac.in>

Applied, thanks.
