From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4 3/9] static_key: WARN on usage before jump_label_init was called
Date: Thu, 7 Nov 2013 01:50:27 +0100
Message-ID: <20131107005027.GC8144@order.stressinduktion.org>
References: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org> <1382212139-20301-4-git-send-email-hannes@stressinduktion.org> <20131106161649.2bb1dbb0@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andi Kleen <andi@firstfloor.org>,
	Ingo Molnar <mingo@kernel.org>, Jason Baron <jbaron@akamai.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131106161649.2bb1dbb0@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 06, 2013 at 04:16:49PM -0500, Steven Rostedt wrote:
> Sorry for the late reply, but this was sent while I was getting ready
> for my two week conference trip.
> 
> Note, this should not go through the net tree, but instead should go
> through tip, as it deals with jump labels and not networking.
> 
> Otherwise, this patch looks good.
> 
> Reviewed-by: Steven Rostedt <rostedt@goodmis.org>

Thanks for the review!

The patch already got queued up in net-next. Is this ok or what do you
suggest to resolve this?

Greetings,

  Hannes
