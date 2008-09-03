From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2.6.27-rc5] net/usb/pegasus.c -- avoid hundreds of diagnostics
Date: Wed, 03 Sep 2008 09:27:15 -0400
Message-ID: <48BE90B3.8000207@pobox.com>
References: <200809021134.24562.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network development list <netdev@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46157 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752237AbYICN1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 09:27:19 -0400
In-Reply-To: <200809021134.24562.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:
> From: David Brownell <dbrownell@users.sourceforge.net>
> 
> Make the "pegasus" driver scream less loudly in the face of
> problems as it initializes, avoiding hundreds of messages:
> 
>  - ratelimit some key error messages
>  - avoid some spurious diagnostics caused by strange codeflow
> 
> And fix one instance of goofy indentation.
> 
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>

applied


