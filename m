From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Sat, 28 Mar 2015 16:55:36 +0300
Message-ID: <5516B2D8.6010006@cogentembedded.com>
References: <2926619.fiYHPz1IBk@wasted.cogentembedded.com> <55163959.8080101@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <55163959.8080101@gmx.de>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 3/28/2015 8:17 AM, Lino Sanfilippo wrote:

>> +	spinlock_t lock;		/* Register access lock */

> Do you really need one huge lock for all register accesses? Maybe you

    AFAIK, this is the usual practice.

> Regards,
> Lino

WBR, Sergei

