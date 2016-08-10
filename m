From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v3 13/13] net: ethernet: ti: cpsw: move ale, cpts and
 drivers params under cpsw_common
Date: Wed, 10 Aug 2016 21:18:03 +0530
Message-ID: <2d78ce21-08ec-5533-8208-ca670b008d02@ti.com>
References: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1470784964-26440-14-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<netdev@vger.kernel.org>, <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470784964-26440-14-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 10 August 2016 04:52 AM, Ivan Khoronzhuk wrote:
> The ale, cpts, version, rx_packet_max, bus_freq, interrupt pacing
> parameters are common per net device that uses the same h/w. So,
> move them to common driver structure.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
