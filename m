From: James Morris <jmorris@namei.org>
Subject: Re: [RFC/PATCH 2/2] update sunrpc to use in-kernel sockets API
Date: Tue, 13 Jun 2006 18:13:38 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606131812070.6488@d.namei>
References: <1150156564.19929.33.camel@w-sridhar2.beaverton.ibm.com>
 <Pine.LNX.4.64.0606122320010.31627@d.namei> <448E42AE.1010901@us.ibm.com>
 <Pine.LNX.4.64.0606131006250.3553@d.namei> <1150215626.31720.9.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:11746 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932289AbWFMWNk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 18:13:40 -0400
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <1150215626.31720.9.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Jun 2006, Sridhar Samudrala wrote:

> My patch doesn't touch this section of the code and this is called 
> after the assignment we are talking about. So we should be using the
> right sendpage in the actual call.

Ok.

Acked-by: James Morris <jmorris@namei.org>

(for both patches).

-- 
James Morris
<jmorris@namei.org>
