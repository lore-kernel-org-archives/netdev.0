From: Luciano Coelho <coelho@ti.com>
Subject: Re: [PATCH 14/14] wlcore: Remove redundant check on unsigned
 variable
Date: Fri, 16 Nov 2012 20:24:36 +0200
Message-ID: <1353090276.10872.84.camel@cumari.coelho.fi>
References: <1353048646-10935-1-git-send-email-tushar.behera@linaro.org>
	 <1353048646-10935-15-git-send-email-tushar.behera@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <patches@linaro.org>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: Tushar Behera <tushar.behera@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353048646-10935-15-git-send-email-tushar.behera@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-11-16 at 12:20 +0530, Tushar Behera wrote:
> No need to check whether unsigned variable is less than 0.
> 
> CC: Luciano Coelho <coelho@ti.com>
> CC: linux-wireless@vger.kernel.org
> CC: netdev@vger.kernel.org
> Signed-off-by: Tushar Behera <tushar.behera@linaro.org>
> ---

Applied in the wl12xx.git tree.  Thanks!

--
Luca.
