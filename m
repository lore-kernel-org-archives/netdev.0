From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [patch net-next v2 1/2] devlink: add hardware messages tracing
 facility
Date: Tue, 12 Jul 2016 13:23:59 -0400
Message-ID: <20160712132359.7eec5002@gandalf.local.home>
References: <1468339504-27580-1-git-send-email-jiri@resnulli.us>
	<20160712123826.15a31a41@gandalf.local.home>
	<20160712171046.GA1799@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	yotamg@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com, ivecera@redhat.com, mingo@redhat.com,
	jolsa@kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0224.hostedemail.com ([216.40.44.224]:54914 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750874AbcGLRYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 13:24:05 -0400
In-Reply-To: <20160712171046.GA1799@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jul 2016 19:10:46 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Tue, Jul 12, 2016 at 06:38:26PM CEST, rostedt@goodmis.org wrote:
> >On Tue, 12 Jul 2016 18:05:03 +0200
> >Jiri Pirko <jiri@resnulli.us> wrote:
> >  
> >> From: Jiri Pirko <jiri@mellanox.com>
> >> 
> >> Define a tracepoint and allow user to trace messages going to and from
> >> hardware associated with devlink instance.
> >> 
> >> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> >> ---
> >> v1->v2:
> >> - Use EXPORT_TRACEPOINT_SYMBOL_GPL instead of a wrapper function
> >>   as suggested by David Ahern and Steven Rostedt  
> >
> >FYI, you can use the Suggested-by: tag too ;-)  
> 
> Thought that the purpose of that tag is if someone suggested the whole
> patch existence.

Yeah, it has different meanings. You could always be creative and add: 

Parts-suggested-by: ....

;-)

-- Steve
