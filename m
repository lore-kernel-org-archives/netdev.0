From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/7] net: qrtr: Fixes and support receiving version
 2 packets
Date: Wed, 11 Oct 2017 15:38:50 -0700 (PDT)
Message-ID: <20171011.153850.552840530998950562.davem@davemloft.net>
References: <20171011064523.7902-1-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, clew@codeaurora.org
To: bjorn.andersson@linaro.org
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20171011064523.7902-1-bjorn.andersson@linaro.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Andersson <bjorn.andersson@linaro.org>
Date: Tue, 10 Oct 2017 23:45:16 -0700

> On the latest Qualcomm platforms remote processors are sending packets with
> version 2 of the message header. This series starts off with some fixes and
> then refactors the qrtr code to support receiving messages of both version 1
> and version 2.
> 
> As all remotes are backwards compatible transmitted packets continues to be
> send as version 1, but some groundwork has been done to make this a per-link
> property.

Series applied, thanks.
