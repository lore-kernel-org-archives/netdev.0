From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/15] net: emaclite: Convert to use
 devm_ioremap_resource
Date: Wed, 12 Jun 2013 02:23:39 -0700 (PDT)
Message-ID: <20130612.022339.1135376738847009456.davem@davemloft.net>
References: <1370864113-17895-1-git-send-email-tushar.behera@linaro.org>
	<1370864113-17895-9-git-send-email-tushar.behera@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, thierry.reding@gmail.com,
	patches@linaro.org, netdev@vger.kernel.org, michal.simek@xilinx.com
To: tushar.behera@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370864113-17895-9-git-send-email-tushar.behera@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tushar Behera <tushar.behera@linaro.org>
Date: Mon, 10 Jun 2013 17:05:06 +0530

> Commit 75096579c3ac ("lib: devres: Introduce devm_ioremap_resource()")
> introduced devm_ioremap_resource() and deprecated the use of
> devm_request_and_ioremap().
> 
> Signed-off-by: Tushar Behera <tushar.behera@linaro.org>

Applied.
