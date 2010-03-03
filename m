From: Pavel Roskin <proski@gnu.org>
Subject: Re: Current wireless-testing breaks libpcap: mr_alen should be set
Date: Wed, 03 Mar 2010 01:57:28 -0500
Message-ID: <20100303015728.6fela7gsg0oooso0-cebfxv@webmail.spamcop.net>
References: <1267578048.14049.11.camel@mj>
	<20100303062359.GA2648@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:3075 "EHLO c60.cesmail.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754722Ab0CCG53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 01:57:29 -0500
In-Reply-To: <20100303062359.GA2648@psychotron.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Jiri Pirko <jpirko@redhat.com>:

> Sorry about this. Corrected patch will follow.

I guess the address length should not be checked if the address is not  
supplied, as in this case.

-- 
Regards,
Pavel Roskin
