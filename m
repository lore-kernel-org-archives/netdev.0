From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/15] net: can: Convert to use devm_ioremap_resource
Date: Wed, 12 Jun 2013 02:23:45 -0700 (PDT)
Message-ID: <20130612.022345.638990137181901830.davem@davemloft.net>
References: <1370864113-17895-1-git-send-email-tushar.behera@linaro.org>
	<1370864113-17895-10-git-send-email-tushar.behera@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, thierry.reding@gmail.com,
	patches@linaro.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, mkl@pengutronix.de, wg@grandegger.com
To: tushar.behera@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370864113-17895-10-git-send-email-tushar.behera@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tushar Behera <tushar.behera@linaro.org>
Date: Mon, 10 Jun 2013 17:05:07 +0530

> Commit 75096579c3ac ("lib: devres: Introduce devm_ioremap_resource()")
> introduced devm_ioremap_resource() and deprecated the use of
> devm_request_and_ioremap().
> 
> Signed-off-by: Tushar Behera <tushar.behera@linaro.org>

Applied.
