From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH V2] net/sched: sch_plug - Queue traffic until an
 explicit release command
Date: Mon, 30 Jan 2012 09:45:56 -0500
Message-ID: <1327934756.2243.3.camel@mojatatu>
References: <1327823619-29274-1-git-send-email-rshriram@cs.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Brendan Cully <brendan@cs.ubc.ca>
To: Shriram Rajagopalan <rshriram@cs.ubc.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:47651 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753438Ab2A3OqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:46:04 -0500
Received: by vbbfc26 with SMTP id fc26so2863787vbb.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 06:46:03 -0800 (PST)
In-Reply-To: <1327823619-29274-1-git-send-email-rshriram@cs.ubc.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please address the comment from Hagen on the printk (kill it).
Other than that i think this simple enough and non-intrusive
to other users that you can add an Acked-by from me.
It will be nice to get it to be generic as per Hagen's and my
earlier comments. 

cheers,
jamal
