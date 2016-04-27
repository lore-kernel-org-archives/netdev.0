From: Andy Gross <andy.gross@linaro.org>
Subject: Re: [PATCH v3 1/2] soc: qcom: smd: Introduce compile stubs
Date: Wed, 27 Apr 2016 14:32:05 -0500
Message-ID: <CAPBZ5QfztsoDpTX=KdEvrHLZmAopR8JooEL0p+MAc6YiwBKS3w@mail.gmail.com>
References: <1461784383-2978-1-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1461784383-2978-1-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27 April 2016 at 14:13, Bjorn Andersson <bjorn.andersson@linaro.org> wrote:
> Introduce compile stubs for the SMD API, allowing consumers to be
> compile tested.
>
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
> ---
>
> Changes since v2:
> - Introduce this patch, to allow compile testing of QRTR_SMD
>
>  include/linux/soc/qcom/smd.h | 28 +++++++++++++++++++++++++++-
>  1 file changed, 27 insertions(+), 1 deletion(-)
>

Looks ok.

Acked-by: Andy Gross <andy.gross@linaro.org>
