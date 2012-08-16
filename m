From: Joe Perches <joe@perches.com>
Subject: Re: smsc75xx maintainer?
Date: Thu, 16 Aug 2012 12:12:35 -0700
Message-ID: <1345144355.26882.23.camel@joe2Laptop>
References: <CANEJEGuh++1-7HajcK65a=NPyKY_5JWkjGQFOKddv4JrVn0gFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Grant Grundler <grundler@google.com>,
	Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:45685 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753209Ab2HPTMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 15:12:37 -0400
In-Reply-To: <CANEJEGuh++1-7HajcK65a=NPyKY_5JWkjGQFOKddv4JrVn0gFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-15 at 14:48 -0700, Grant Grundler wrote:
> scripts/get_maintainer.pl can't identify an owner for
> drivers/net/usb/smsc75xx.c (USB GigE dongle).

Maybe add --file-emails or --interactive to try harder.

> Anyone (at SMSC?) interested in fixing suspend/resume for smsc75xx driver?
> 
> I don't have time to chase this but it would be nice if this part
> worked. Only suspend/resume appears broken.
> 
> Some details in http://crosbug.com/31871.

MODULE_AUTHOR("Steve Glendinning <steve.glendinning@shawell.net>");

Maybe Steve?  (cc'd)
