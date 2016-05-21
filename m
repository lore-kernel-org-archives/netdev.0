From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: IPv6 extension header privileges
Date: Sat, 21 May 2016 06:02:31 -0400
Message-ID: <20160521100231.GE2452@oracle.com>
References: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
 <1e22f140-920e-0d1c-4a43-03780fb380a8@stressinduktion.org>
 <20160521015604.GD2452@oracle.com>
 <1463823275.2335717.614453105.5011B2EE@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25783 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbcEUKCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 06:02:42 -0400
Content-Disposition: inline
In-Reply-To: <1463823275.2335717.614453105.5011B2EE@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (05/21/16 11:34), Hannes Frederic Sowa wrote:
> 
> My wording directly from the RFC was too strong, true, but given that
> there is a CALIPSO patch already floating around for the kernel and
> those options are strictly controlled by selinux policy and build the
> foundation for the networking separation we can't make it simply
> non-priv.

sure, I agree with that point.

--Sowmini
