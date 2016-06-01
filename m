From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] ravb: Remove manual pause frame transmit
Date: Wed, 1 Jun 2016 19:53:35 +0300
Message-ID: <e9552754-81e2-e39d-3218-8988826cb212@cogentembedded.com>
References: <1464799265-27431-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1464799265-27431-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/01/2016 07:41 PM, Yoshihiro Kaneko wrote:

> From: Masaru Nagai <masaru.nagai.vx@renesas.com>
>
> Writing a non-zero value to the manual PAUSE frame register (MPR) starts
> the transmission of a PAUSE frame.
> A PAUSE frame is sent in ravb_emac_init(), but it is not expected behavior.
>
> Signed-off-by: Masaru Nagai <masaru.nagai.vx@renesas.com>
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
