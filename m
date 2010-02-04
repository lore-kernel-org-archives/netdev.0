From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] dccp: fix auto-loading of dccp(_probe)
Date: Wed, 03 Feb 2010 19:01:42 -0800 (PST)
Message-ID: <20100203.190142.123408896.davem@davemloft.net>
References: <20100202153929.GA12697@hmsreliant.think-freely.org>
	<20100203061656.GA5415@gerrit.erg.abdn.ac.uk>
	<20100203115840.GA651@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47316
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752605Ab0BDDBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 22:01:30 -0500
In-Reply-To: <20100203115840.GA651@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 3 Feb 2010 06:58:40 -0500

> On Wed, Feb 03, 2010 at 07:16:56AM +0100, Gerrit Renker wrote:
>> Hi Neil,
>> 
>> I have tested your patch, it works fine thanks to the repeated execution of the macro
>> argument. I have reformatted it, removing the inner parentheses, which I think is
>> justified since macros copy their arguments in full. Also converted your email to a
>> drafted commit message. Due to this, have not copied your signed-off -- if you are
>> ok, please add, this should be submitted asap.
>> 
> Understood, and thank you.  This looks fine to me
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks.
