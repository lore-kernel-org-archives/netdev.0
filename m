From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: SCTP control socket question
Date: Thu, 27 Mar 2008 17:15:53 +0300
Message-ID: <47EBAC19.2050301@openvz.org>
References: <1206619433.32459.9.camel@iris.sw.ru>  <47EB9794.7010407@hp.com>	 <1206623398.32459.19.camel@iris.sw.ru>  <47EB9E0B.2030400@hp.com> <1206625405.2109.7.camel@iris.sw.ru> <47EBA8A7.4080503@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>,
	lksctp-developers@lists.sourceforge.net
To: Vlad Yasevich <vladislav.yasevich@hp.com>,
	"Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50129 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757450AbYC0OQH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 10:16:07 -0400
In-Reply-To: <47EBA8A7.4080503@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> will you mind against this?
>>
> 
> That's fine.  My one concern is that someone may erroneously interpret that SCTP
> sockets are derived from inet_connection_sock, but I can live with that.

Agree. I'd rename it into some not-so-inet-related function.

> -vlad 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

