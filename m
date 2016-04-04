From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 10/15] wcn36xx: Copy all members in config_sta v1
 conversion
Date: Mon, 4 Apr 2016 15:25:52 +0300
Message-ID: <57025D50.70505@cogentembedded.com>
References: <1459721806-11817-1-git-send-email-bjorn.andersson@linaro.org>
 <1459721806-11817-10-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pontus Fuchs <pontus.fuchs@gmail.com>, wcn36xx@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bjorn Andersson <bjorn.andersson@linaro.org>,
	Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459721806-11817-10-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/4/2016 1:16 AM, Bjorn Andersson wrote:

> From: Pontus Fuchs <pontus.fuchs@gmail.com>
>
> When converting to version 1 of the config_sta struct not all
> members where copied. This fixes the problem of multicast frames

    Were.

> not being delivered on an encrypted network.
>
> Signed-off-by: Pontus Fuchs <pontus.fuchs@gmail.com>
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
[...]

MBR, Sergei
