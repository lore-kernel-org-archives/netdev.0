From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [PATCH][BNX2X] round three - sparse warnings.
Date: Thu, 11 Oct 2007 19:21:37 +0200
Message-ID: <1192123297.29746.130.camel@eliezer>
References: <1192038559.29746.127.camel@eliezer>
 <470D2D7E.8080507@broadcom.com>
 <20071010185455.79dafc7b@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2294 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753651AbXJKRUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 13:20:21 -0400
In-Reply-To: <20071010185455.79dafc7b@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-10-10 at 18:54 -0700, Stephen Hemminger wrote:
> Please fix these...
> 

Thanks, 
All that code is going to be rewritten, as per Dave's request,
but I will make sure to test the new code with sparse.

Eliezer



