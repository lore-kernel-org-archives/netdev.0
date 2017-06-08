From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH 0/4] Missing QRTR features
Date: Thu, 08 Jun 2017 11:35:22 -0400 (EDT)
Message-ID: <20170608.113522.1009136088878719137.davem@davemloft.net>
References: <20170607210739.27263-1-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aneela@codeaurora.org, netdev@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org,
        ccavin@gmail.com
To: bjorn.andersson@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607210739.27263-1-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Andersson <bjorn.andersson@linaro.org>
Date: Wed,  7 Jun 2017 14:07:35 -0700

> The QMUX specification covers packet routing as well as service life cycle and
> discovery. The current implementation of qrtr supports the prior part, but in
> order to fully implement service management on-top a few more parts are needed.
> 
> The first patch in the series serves the purpose of reducing duplication in
> patch two and three.
> 
> The second and third patch adds two qrtr-level notifications required by the
> specification, in order to notify local and remote service controllers about
> dying clients.
> 
> The last patch serves the purpose of notifying local clients about the presence
> of a local service register, allowing them to register services as well as
> querying for remote registered services.

Looks good, series applied to net-next, thank you.
