From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH v2 1/2] net: ethernet: ti: cpsw: remove rx_descs property
Date: Sat, 11 Jun 2016 13:11:29 +0300
Message-ID: <575BE3D1.5000507@linaro.org>
References: <1465307976-12235-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1465307976-12235-2-git-send-email-ivan.khoronzhuk@linaro.org>
 <20160610.225043.1035032413161700163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, linux-kernel@vger.kernel.org,
	grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, bcousson@baylibre.com, tony@atomide.com,
	devicetree@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160610.225043.1035032413161700163.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11.06.16 08:50, David Miller wrote:
> From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> Date: Tue,  7 Jun 2016 16:59:35 +0300
>
>>   	if (!cpsw_common_res_usage_state(priv)) {
>> +		int buf_num;
>>   		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(priv, 0);
>>
>
> Please always order local variable declarations from longest to shortest
> line.
>
I will correct it in v3



-- 
Regards,
Ivan Khoronzhuk
