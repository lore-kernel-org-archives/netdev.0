From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH RESEND] ssb: Fix Sparse error in main
Date: Wed, 28 Jan 2015 08:13:54 +0100
Message-ID: <CACna6rw5uqB=KZjcao8kLvQ0rgCuqOo7KkyReMF3ZoT0ZH4U=Q@mail.gmail.com>
References: <1422424187-19059-1-git-send-email-pramod.gurav@smartplayin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <m@bues.ch>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Pramod Gurav <pramod.gurav@smartplayin.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422424187-19059-1-git-send-email-pramod.gurav@smartplayin.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28 January 2015 at 06:49, Pramod Gurav <pramod.gurav@smartplayin.com> wrote:
> This change fixes below sparse error:
> drivers/ssb/main.c:94:16: warning: symbol 'ssb_sdio_func_to_bus'
> was not declared. Should it be static?

Seems like it was never used. Looks OK.
