From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 2/2] iplink: print out addrgenmode attribute
Date: Thu, 8 Jan 2015 08:04:39 +0100
Message-ID: <20150108070439.GB1860@nanopsycho.orion>
References: <1420561426-3118-1-git-send-email-jiri@resnulli.us>
 <1420561426-3118-2-git-send-email-jiri@resnulli.us>
 <20150107151036.2852e1be@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, thaller@redhat.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38958 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753142AbbAHHEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 02:04:41 -0500
Received: by mail-wi0-f179.google.com with SMTP id ex7so1284455wid.0
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 23:04:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150107151036.2852e1be@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 08, 2015 at 12:10:36AM CET, stephen@networkplumber.org wrote:
>On Tue,  6 Jan 2015 17:23:46 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> addrgenmode is currently write only by ip. So display this information
>> if provided by kernel as well.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Patch does not apply to current iproute2 git

I made that against net-next branch. Which branch should I use for new
features?
