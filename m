From: Peter Wu <peter@lekensteyn.nl>
Subject: Re: [PATCH] net: wireless: rtlwifi: rtl8192de: hw.c: Cleaning up conjunction always evaluates to false
Date: Sun, 08 Jun 2014 12:43:25 +0200
Message-ID: <3239222.FyGtueg2aO@al>
References: <1402151419-18296-1-git-send-email-rickard_strandqvist@spectrumdigital.se> <1436639.AmJiDmeQZF@al> <CAFo99gb2gzLjv_4b3O-e0B1R8P5BTGbPJLuYYAmoyww9hkmrvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFo99gb2gzLjv_4b3O-e0B1R8P5BTGbPJLuYYAmoyww9hkmrvA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 08 June 2014 12:36:11 Rickard Strandqvist wrote:
> Then we use MSR_MASK instead, new patch then. But I will wait a day?
> Or what is long enough to be sure that nobody else have any
> objections? How is this usually resolved?

Well, Larry is the maintainer, so he will ultimately pick up patches.
One or two days should give people some time to read and reply.

As for MSR_MASK, that macro does not exist yet, I was wondering whether
it's OK to add a new macro? (Larry?)

> Sure, I can send a patch for all the files instead. However, earlier
> received complaints when I sent patches extending over more than one
> file.
> 
> I'll check again how the cover letter works. Although when I try with
> my send patch mail script it did not work as I wanted.

See the manual page git-send-email(1) and git-format-patch(1). In
particular the Example section of git-send-email(1).

Kind regards,
Peter
