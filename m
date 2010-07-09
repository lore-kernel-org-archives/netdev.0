From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v4 1/9] atm: propagate signal changes via notifier
Date: Fri, 9 Jul 2010 07:16:10 -0400
Message-ID: <20100709071610.42473d6c@thirdoffive.cmf.nrl.navy.mil>
References: <1278578095-25324-1-git-send-email-karl@hiramoto.org>
	<1278578095-25324-2-git-send-email-karl@hiramoto.org>
	<20100708.214745.48520104.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: karl@hiramoto.org, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:37851 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755804Ab0GILQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 07:16:48 -0400
In-Reply-To: <20100708.214745.48520104.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 08 Jul 2010 21:47:45 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Karl Hiramoto <karl@hiramoto.org>
> Date: Thu,  8 Jul 2010 10:34:47 +0200
> 
> /* Like
>  * this.
>  */
> 
> not:
> 
> /*
>  * Like
>  * this.
>  */
> 
> Honestly, I don't know how I can be more clear about this :-)

this is somewhat contrary to the suggested multi-line format given in
Documentation/CodingStyle:


The preferred style for long (multi-line) comments is:

        /*
         * This is the preferred style for multi-line
         * comments in the Linux kernel source code.
         * Please use it consistently.
         *
         * Description:  A column of asterisks on the left side,
         * with beginning and ending almost-blank lines.
         */
