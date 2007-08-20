From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: 2.6.23-rc3 and SKY2 driver issue
Date: Mon, 20 Aug 2007 09:02:27 -0700
Message-ID: <20070820090227.6ceb2934@freepuppy.rosehill.hemminger.net>
References: <20070816090556.6a5295e6@oldman>
	<370212.9287.qm@web90407.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: James Corey <ploversegg@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39468 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760891AbXHTQDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 12:03:04 -0400
In-Reply-To: <370212.9287.qm@web90407.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Aug 2007 08:42:21 -0700 (PDT)
James Corey <ploversegg@yahoo.com> wrote:

> 
> --- Stephen Hemminger
> <shemminger@linux-foundation.org> wrote:
> 
> > On Thu, 16 Aug 2007 10:25:45 +0200
> > "Michal Piotrowski"
>
> > Please reproduce with a more recent kernel?
> 
> Um, I thought 2.6.23rc WAS pretty recent. :-)
> 
> I'll check if there is something newer in the
> repository now.
> 

What is the chip version?  Please send console log: "dmesg | grep sky2"


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
