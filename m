From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: oh crap...
Date: Wed, 29 Oct 2008 11:31:44 -0700
Message-ID: <1225305104.5688.29.camel@brick>
References: <1225292124.20276.12.camel@brick>
	 <1225294760.5269.301.camel@localhost> <1225301082.5688.24.camel@brick>
	 <20081029.112852.153175366.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:22102 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753059AbYJ2Sbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 14:31:47 -0400
Received: by wf-out-1314.google.com with SMTP id 27so125729wfd.4
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 11:31:46 -0700 (PDT)
In-Reply-To: <20081029.112852.153175366.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-29 at 11:28 -0700, David Miller wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Date: Wed, 29 Oct 2008 10:24:42 -0700
> 
> > %pI6, %pi6
> > 	%pI6 would act just like %p6
> > 	%pi6 would act just like %#p6
> 
> I think this form is not a bad idea.
> 
> Please send me the patch that does this.
> 
> And will you be sending the ipv4 side stuff next?
> 

I can do if you'd like it, I'll sneak %pI4 into the patch fixing up
the warnings I've made and do a conversion of the IPv4 stuff later this
week.

Cheers,

Harvey

