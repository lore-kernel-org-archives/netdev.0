From: Matt Mackall <mpm@selenic.com>
Subject: Re: netconsole as normal console for userspace messages?
Date: Tue, 01 Sep 2009 10:15:11 -0500
Message-ID: <1251818111.3960.425.camel@calx>
References: <20090901101612.GB5222@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([173.11.57.241]:41109 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753821AbZIAPPh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 11:15:37 -0400
In-Reply-To: <20090901101612.GB5222@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-09-01 at 10:16 +0000, Jarek Poplawski wrote:
> On 30-08-2009 02:12, Arkadiusz Miskiewicz wrote:
> > Hi,
> Hi,
> 
> > 
> > Can netconsole be somehow used to see userspace messages, too? Something 
> > similar to console=ttySX... just =netconsole.
> > 
> 
> AFAIK it can't, but AFAICR some time ago the netconsole maintainer
> gave some hope to some Debian guy with a similar question.

It is, as they say, just a simple matter of programming to get a full
bidirectional console out of it. As cool as that would be, I just
haven't had time for it.

-- 
http://selenic.com : development and support for Mercurial and Linux


