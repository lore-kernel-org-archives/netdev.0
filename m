From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] sunvnet: improve error handling when a remote
 crashes
Date: Mon, 26 Jan 2015 17:45:30 -0500
Message-ID: <20150126224530.GH6437@oracle.com>
References: <54C6911B.5040501@oracle.com>
 <20150126195403.GE6437@oracle.com>
 <54C6A154.3090906@oracle.com>
 <54C6A3BA.3060004@oracle.com>
 <54C6A95F.8010602@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:27003 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753568AbbAZWpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 17:45:34 -0500
Content-Disposition: inline
In-Reply-To: <54C6A95F.8010602@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/26/15 15:53), David L Stevens wrote:
> 
> I demoted it to a notice and we can change it to a counter when we add
> stats. This way it's clear that it's an unexpected state and it's easy
> to see them when we want them.

fair enough.

--Sowmini
