From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: drivers/net/chelsio/sge.c: two array overflows
Date: Thu, 16 Mar 2006 19:21:46 -0500
Message-ID: <441A011A.6010705@pobox.com>
References: <20060311013720.GG21864@stusta.de> <4415C87B.90107@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, maintainers@chelsio.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752437AbWCQAWE@vger.kernel.org>
To: Scott Bardone <sbardone@chelsio.com>
In-Reply-To: <4415C87B.90107@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Scott Bardone wrote:
> Adrian,
> 
> This is a bug. The array should contain 2 elements.
> 
> Attached is a patch which fixes it.
> Thanks.
> 
> Signed-off-by: Scott Bardone <sbardone@chelsio.com>

applied.  please avoid attachments and use a proper patch description in 
the future.  I had to hand-edit and hand-apply your patch.

See http://linux.yyz.us/patch-format.html for more info, or use git.

	Jeff
