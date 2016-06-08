From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net 0/2] cls_u32 hardware offload fixes
Date: Wed, 8 Jun 2016 20:18:55 +0100
Message-ID: <20160608201855.6d8b0e24@jkicinski-Precision-T1700>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
	<20160607.162731.1154473267162142674.davem@davemloft.net>
	<20160608111830.6ca8db51@jkicinski-Precision-T1700>
	<20160608.110936.851389252396914415.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	sridhar.samudrala@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38679 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161420AbcFHTTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 15:19:01 -0400
Received: by mail-wm0-f52.google.com with SMTP id m124so30473585wme.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 12:19:00 -0700 (PDT)
In-Reply-To: <20160608.110936.851389252396914415.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 08 Jun 2016 11:09:36 -0700 (PDT), David Miller wrote:
> From: Jakub Kicinski <jakub.kicinski@netronome.com>
> Date: Wed, 8 Jun 2016 11:18:30 +0100
> 
> > On Tue, 07 Jun 2016 16:27:31 -0700 (PDT), David Miller wrote:  
> >> From: Jakub Kicinski <jakub.kicinski@netronome.com>
> >> Date: Mon,  6 Jun 2016 16:16:46 +0100
> >>   
> >> > This set fixes two small issues with error codes I noticed
> >> > in cls_u32.  Second patch could be viewed as user space API
> >> > change but that portion of API is not part of any release,
> >> > yet.
> >> > 
> >> > Compile tested only.    
> >> 
> >> Applied, thanks.  
> > 
> > I think you applied v1 instead of v3 (which is still in patchwork) :S
> > Should I post an incremental patch to bring the code to v3 state?  
> 
> Yeah please do, sorry about that :-/

Done and marked v3 as Superseded, hope that's OK!
