From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: ethtool patch to support bypass / fail-to-wire function
Date: Wed, 11 Jun 2014 11:35:58 -0700
Message-ID: <20140611113558.6d0c6296@nehalam.linuxnetplumber.net>
References: <3BFAEADE799AF145974162DF00E013AF018F794DE5@exchange2010.silicom.local>
	<1402322812.23860.76.camel@deadeye.wl.decadent.org.uk>
	<3BFAEADE799AF145974162DF00E013AF018F798C22@exchange2010.silicom.local>
	<20140611091757.78e1002d@nehalam.linuxnetplumber.net>
	<3BFAEADE799AF145974162DF00E013AF018F79A137@exchange2010.silicom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Elad Blatt <eladb@silicom.co.il>
To: David Hendel <david@silicom.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:60674 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753293AbaFKSgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 14:36:02 -0400
Received: by mail-pd0-f175.google.com with SMTP id z10so91038pdj.20
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 11:36:01 -0700 (PDT)
In-Reply-To: <3BFAEADE799AF145974162DF00E013AF018F79A137@exchange2010.silicom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Jun 2014 16:55:27 +0000
David Hendel <david@silicom.co.il> wrote:

> Stephen,
> OK, so what should be the next step? How do we move forward with that?
> 
> Regards, David
> 
> 
> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org] 
> Sent: Wednesday, June 11, 2014 7:18 PM
> To: David Hendel
> Cc: netdev@vger.kernel.org; Elad Blatt
> Subject: Re: ethtool patch to support bypass / fail-to-wire function
> 
> The driver using this is not upstream. You need to get that driver reviewed and incorporated in upstream kernel before the changes to ethtool will be considered.
> 
> I expect that the driver will not be accepted as is, and therefore you will have to make changes (including API changes), that render this ethtool API moot.
> 
> 

Read kernel/Documentation/SubmittingPatches
