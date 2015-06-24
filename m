From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [patch -next] renesas: missing unlock on error path
Date: Wed, 24 Jun 2015 19:53:59 +0300
Message-ID: <558AE0A7.5000507@cogentembedded.com>
References: <20150624143254.GG1702@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Masaru Nagai <masaru.nagai.vx@renesas.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150624143254.GG1702@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/24/2015 05:32 PM, Dan Carpenter wrote:

> We need to unlock before returning here.

     Indeed. Sorry about missing that.

> Fixes: a0d2f20650e8 ('Renesas Ethernet AVB PTP clock driver')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

WBR, Sergei

