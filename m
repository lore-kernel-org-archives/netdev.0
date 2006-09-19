From: Mike Galbraith <efault@gmx.de>
Subject: Re: patch blocked
Date: Tue, 19 Sep 2006 11:03:55 +0000
Message-ID: <1158663835.6137.2.camel@Homer.simpson.net>
References: <1158654797.3526.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:28899 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1751615AbWISIwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 04:52:14 -0400
To: Zang Roy-r61911 <tie-fei.zang@freescale.com>
In-Reply-To: <1158654797.3526.14.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-09-19 at 16:33 +0800, Zang Roy-r61911 wrote:
> Hi,
> 	Does anyone can tell me why some of my patches were blocked in the
> mailing list.
> 	I do not use attachment. The body of the mail is not exceed 40KB in
> size.
> Roy

A snippet from the 'Bogofilter at VGER' announcment:

...

IF we take it into use, it will start rejecting messages
at SMTP input phase, so if it rejects legitimate message,
you should get a bounce from your email provider's system.
(Or from zeus.kernel.org, which is vger's backup MX.)

In such case, send the bounce with some explanations to 
<postmaster@vger.kernel.org> -- emails to that address
are explicitely excluded from all filtering!


