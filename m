From: Andrei Emeltchenko <andrei.emeltchenko.news@gmail.com>
Subject: Re: [PATCH 0/2] Add and use vsprintf extension %pMbt for bluetooth
 macs
Date: Wed, 9 May 2012 12:01:58 +0300
Message-ID: <20120509090156.GB8473@aemeltch-MOBL1>
References: <cover.1291419007.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1291419007.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe

On Fri, Dec 03, 2010 at 06:33:02PM -0800, Joe Perches wrote:
> Using vsprintf extensions can save text and data.
> Add %pMbt for the byte reversed output for bluetooth addresses.
> 
> Joe Perches (2):
>   vsprintf: Add %pMbt, bluetooth mac address
>   bluetooth: Use printf extension %pMbt

I think this would be the best way to solve our issues with batostr.

BTW: What is the status with this patch series? I saw that it was acked by
Gustavo but not applied for some reason.

Best regards 
Andrei Emeltchenko 
