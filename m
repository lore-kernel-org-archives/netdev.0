From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ppp_generic: pull 2 bytes so that PPP_PROTO(skb)
 is valid
Date: Mon, 03 May 2010 12:49:02 -0700 (PDT)
Message-ID: <20100503.124902.51283117.davem@davemloft.net>
References: <4BDB244D.40800@simon.arlott.org.uk>
	<20100502.232520.146109082.davem@davemloft.net>
	<e85216b167313bb2bd46f5990ed468f5b67a1ad8@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org, linux-ppp@vger.kernel.org
To: simon@fire.lp0.eu
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <e85216b167313bb2bd46f5990ed468f5b67a1ad8@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Simon Arlott" <simon@fire.lp0.eu>
Date: Mon, 3 May 2010 12:50:04 +0100

> Updated patch attached.

Two things:

1) Please don't post patches as binary attachments, it doesn't get
   queued up properly into patchwork if you post it that way.

2) Always make a fresh email posting for new versions of your patch
   when possible, as this way what to include in the commit log
   message is clear and always applies to the patch posted rather
   than bits and pieces of quoted material from previous postings
   that may or may not apply to the current version of the patch.

So please repost this, and your new 2/2 patch, as clean new submissions.

Thanks.
