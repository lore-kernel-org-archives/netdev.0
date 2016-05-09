From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/2] net: Add Qualcomm IPC router
Date: Sun, 08 May 2016 23:47:33 -0400 (EDT)
Message-ID: <20160508.234733.1365141714260635992.davem@davemloft.net>
References: <1462543748-29187-1-git-send-email-bjorn.andersson@linaro.org>
	<1462543748-29187-2-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.gross@linaro.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	ccavin@gmail.com, courtney.cavin@sonymobile.com,
	bjorn.andersson@sonymobile.com
To: bjorn.andersson@linaro.org
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1462543748-29187-2-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Andersson <bjorn.andersson@linaro.org>
Date: Fri,  6 May 2016 07:09:08 -0700

> From: Courtney Cavin <courtney.cavin@sonymobile.com>
> 
> Add an implementation of Qualcomm's IPC router protocol, used to
> communicate with service providing remote processors.
> 
> Signed-off-by: Courtney Cavin <courtney.cavin@sonymobile.com>
> Signed-off-by: Bjorn Andersson <bjorn.andersson@sonymobile.com>
> [bjorn: Cope with 0 being a valid node id and implement RTM_NEWADDR]
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>

Applied.
