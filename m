From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next,v3] hyperv: Add support for virtual Receive Side
 Scaling (vRSS)
Date: Thu, 20 Mar 2014 00:56:05 +0300
Message-ID: <532A1275.2020208@cogentembedded.com>
References: <1395180922-2776-1-git-send-email-haiyangz@microsoft.com> <20140319.164005.1815461875771862691.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: David Miller <davem@davemloft.net>, haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140319.164005.1815461875771862691.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/19/2014 11:40 PM, David Miller wrote:

>> +extern u8 netvsc_hash_key[];

> We no longer use extern in header file function declarations.

    Wait, this is a variable declaration. :-)

WBR, Sergei
