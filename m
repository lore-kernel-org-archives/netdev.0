From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 2/2] iplink: print out addrgenmode attribute
Date: Thu, 8 Jan 2015 10:19:39 -0800
Message-ID: <20150108101939.075ebe14@urahara>
References: <1420561426-3118-1-git-send-email-jiri@resnulli.us>
	<1420561426-3118-2-git-send-email-jiri@resnulli.us>
	<20150107151036.2852e1be@urahara>
	<20150108070439.GB1860@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thaller@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:44258 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757062AbbAHSTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 13:19:49 -0500
Received: by mail-pd0-f177.google.com with SMTP id ft15so12576750pdb.8
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 10:19:49 -0800 (PST)
In-Reply-To: <20150108070439.GB1860@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Jan 2015 08:04:39 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> Thu, Jan 08, 2015 at 12:10:36AM CET, stephen@networkplumber.org wrote:
> >On Tue,  6 Jan 2015 17:23:46 +0100
> >Jiri Pirko <jiri@resnulli.us> wrote:
> >
> >> addrgenmode is currently write only by ip. So display this information
> >> if provided by kernel as well.
> >> 
> >> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> >
> >Patch does not apply to current iproute2 git
> 
> I made that against net-next branch. Which branch should I use for new
> features?
> 

net-next hasn't been rebased to master. plus unless change is specific to
kernel net-next it should be against master.
