From: Benoit Boissinot <bboissin@gmail.com>
Subject: Re: [2.6 patch] drivers/net/hamradio/baycom_epp.c: cleanups
Date: Thu, 21 Apr 2005 12:25:38 +0200
Message-ID: <40f323d005042103253bf924f2@mail.gmail.com>
References: <20050420165344.GO5489@stusta.de>
Reply-To: Benoit Boissinot <bboissin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: sailer@ife.ee.ethz.ch, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261273AbVDUKZo@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050420165344.GO5489@stusta.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/20/05, Adrian Bunk <bunk@stusta.de> wrote:
> The times when tricky goto's produced better codes are long gone.
> 
> This patch should express the same in a better way, please check whether
> I made any mistake.
> 

By the way, it solves compile errors with gcc-4:
a lot of
drivers/net/hamradio/baycom_epp.c:690: error: jump into statement expression

regards,

Benoit
