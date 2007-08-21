From: "Bob Beers" <bob.beers@gmail.com>
Subject: Re: [PATCH 2/4 - rev2] Add new timeval_to_sec function
Date: Tue, 21 Aug 2007 05:58:58 -0400
Message-ID: <4f6ba3b0708210258k779ff97x87edbb4ace091d0e@mail.gmail.com>
References: <20070820134536.d260585a.varunc@linux.vnet.ibm.com>
	 <20070820075325.43bd8f60@freepuppy.rosehill.hemminger.net>
	 <46CA5E75.9050904@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	socketcan@hartkopp.net, krkumar2@in.ibm.com, varuncha@in.ibm.com
To: "Varun Chandramohan" <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:46449 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbXHUJ67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 05:58:59 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1169614rvb
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2007 02:58:59 -0700 (PDT)
In-Reply-To: <46CA5E75.9050904@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What if the name of the function was more descriptive of what the
 function actually does?  Maybe timeval_ceil_sec()?
