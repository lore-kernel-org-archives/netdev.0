From: Akshay Bhat <akshay.bhat@timesys.com>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Tue, 7 Mar 2017 10:31:15 -0500
Message-ID: <2197294b-e6cf-6c56-1419-3a4f95c29db7@timesys.com>
References: <1484680922-25813-1-git-send-email-akshay.bhat@timesys.com>
 <1484680922-25813-2-git-send-email-akshay.bhat@timesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        Akshay Bhat <nodeax@gmail.com>
To: wg@grandegger.com, mkl@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484680922-25813-2-git-send-email-akshay.bhat@timesys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/17/2017 02:22 PM, Akshay Bhat wrote:
> This patch adds support for the Holt HI-311x CAN controller. The HI311x
> CAN controller is capable of transmitting and receiving standard data
> frames, extended data frames and remote frames. The HI311x interfaces
> with the host over SPI.
> 
> Datasheet: www.holtic.com/documents/371-hi-3110_v-rev-jpdf.do
> 
> Signed-off-by: Akshay Bhat <nodeax@gmail.com>
> ---
> 


Hi Marc,

Wanted to check if this patch can be included in the next kernel release
(4.12).

Thanks,
Akshay
