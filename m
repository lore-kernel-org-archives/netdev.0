From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] use dev_printk() in some net drivers
Date: Tue, 27 Jun 2006 11:13:24 -0400
Message-ID: <44A14B14.6070900@garzik.org>
References: <20060627145145.GA30053@havoc.gtf.org> <44A14A5F.3090607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:6534 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1161098AbWF0PN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 11:13:26 -0400
To: Jiri Slaby <jirislaby@gmail.com>
In-Reply-To: <44A14A5F.3090607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Slaby wrote:
> Don't you consider to use s#dev_printk(KERN_ERR, #dev_err(# macro?

Why, yes.  I had forgotten about those, thanks.

	Jeff


