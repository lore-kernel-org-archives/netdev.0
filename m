From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2] ss: Identify a lot of netlink protocol names
Date: Thu, 30 Oct 2014 17:26:30 +0200
Message-ID: <20141030152630.GA31115@angus-think.wlc.globallogic.com>
References: <1413478018-12373-1-git-send-email-vadim4j@gmail.com>
 <20141029224932.0df2edba@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:51013 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934668AbaJ3Pfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 11:35:45 -0400
Received: by mail-wi0-f179.google.com with SMTP id h11so7770382wiw.0
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 08:35:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20141029224932.0df2edba@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2014 at 10:49:32PM -0700, Stephen Hemminger wrote:
> On Thu, 16 Oct 2014 19:46:58 +0300
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > There were only few Netlink protocol names:
> > 
> >     rtnl, fw, tcpdiag
> > 
> > which were printed on output.
> > So added the other ones.
> > 
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> 
> Please make this driven off of a file in /etc/iproute2/ rather than
> hard coding a big switch in the code.
> 
Yes, good idea, will do.

Regards,
