From: David Ahern <dsahern@gmail.com>
Subject: Re: VRFs and the scalability of namespaces
Date: Mon, 29 Sep 2014 06:34:09 -0600
Message-ID: <542951C1.2050202@gmail.com>
References: <5425EAA6.7040302@gmail.com> <87vbo9kg69.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:43576 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbaI2MeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 08:34:10 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so4444252pad.30
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 05:34:10 -0700 (PDT)
In-Reply-To: <87vbo9kg69.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric

On 9/26/14, 7:25 PM, Eric W. Biederman wrote:
> When you say "proper VRF support" what I hear is that you think
> something new needs to be added to the linux network stack (called a
> VRF) with a new userspace interface that somehow because it lacks
> features is better.

 From my perspective the existing mechanisms do not seem to provide a 
sufficient solution for VRFs.


>> Before droning on even more, does the above provide better context on
>> the general problem?
>
> It provides a rough context on what you are trying to do.  Use linux as
> the OS to run on a switch.
>
> It doesn't actually provide much in the way of context actual problems
> that show up when you try to use network namespaces.  Which is what I
> was expecting the discussion would be about, and which would I expect be
> a productive conversation.

I don't know how else to explain it beyond what I said in the first 
email. I listed several specific examples of how namespaces are not an 
appropriate model for VRFs. Do you disagree on any of those points? Need 
clarification on any of them? ie., What more were you expecting?

David
