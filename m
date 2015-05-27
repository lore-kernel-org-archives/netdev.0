From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] qla4xxx: add a missing include
Date: Wed, 27 May 2015 12:47:57 -0700
Message-ID: <1432756077.4060.424.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432701824.4060.346.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150527.142117.1711665345600870663.davem@davemloft.net>
	 <1432751594.2194.54.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:33354 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361AbbE0TsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 15:48:00 -0400
In-Reply-To: <1432751594.2194.54.camel@HansenPartnership.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-27 at 11:33 -0700, James Bottomley wrote:
> On Wed, 2015-05-27 at 14:21 -0400, David Miller wrote:

> > Yeah it's easiest if I just apply this to net-next, which I've just done,
> > thanks Eric.
> 
> Fine with me.  There's no point creating cross tree hassle for a simple
> include problem.

Note there are other drivers to fix, I'll try to submit patches for
them.
