From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] dsa: b53: remove redundant if
Date: Sun, 31 Jul 2016 13:03:26 +0300
Message-ID: <a26b33b7-f051-b84c-684a-abb586991513@cogentembedded.com>
References: <1469950979-19506-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Heinrich Schuchardt <xypron.glpk@gmx.de>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469950979-19506-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 7/31/2016 10:42 AM, Heinrich Schuchardt wrote:

> For pdata == null the code leaves with an error.
> There is need to check the condition again.

    No need, you mean?

> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
[...]

MBR, Sergei
