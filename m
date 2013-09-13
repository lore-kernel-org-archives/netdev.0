From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: Expand led off fix to include 5720
Date: Thu, 12 Sep 2013 23:11:01 -0400 (EDT)
Message-ID: <20130912.231101.252211030441347649.davem@davemloft.net>
References: <1379019691-4618-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1379019691-4618-1-git-send-email-nsujir@broadcom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Thu, 12 Sep 2013 14:01:31 -0700

> Commit 989038e217e94161862a959e82f9a1ecf8dda152 ("tg3: Don't turn off
> led on 5719 serdes port 0") added code to skip turning led off on port
> 0 of the 5719 since it powered down other ports. This workaround needs
> to be enabled on the 5720 as well.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied and queued up for -stable.
