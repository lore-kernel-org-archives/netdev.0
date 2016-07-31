From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: thunderx: correct bound check in nic_config_loopback
Date: Sun, 31 Jul 2016 12:52:55 +0300
Message-ID: <8826fedc-8419-19a9-28d0-faf46ccc9f9f@cogentembedded.com>
References: <1469933384-16827-1-git-send-email-alexander.levin@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Levin, Alexander" <alexander.levin@verizon.com>,
	"sgoutham@cavium.com" <sgoutham@cavium.com>,
	"rric@kernel.org" <rric@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469933384-16827-1-git-send-email-alexander.levin@verizon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 7/31/2016 5:49 AM, Levin, Alexander wrote:

> Off by one in nic_config_loopback would access an invalid arrat variable when

    Array?

> vf id == MAX_LMAC.
>
> Signed-off-by: Sasha Levin <alexander.levin@verizon.com>
[...]

MBR, Sergei
