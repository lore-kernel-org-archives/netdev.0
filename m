From: Chei-yol Kim <gauri@etri.re.kr>
Subject: Re: [RFC] Control Group Classifier
Date: Wed, 8 Oct 2008 07:02:02 +0000 (UTC)
Message-ID: <loom.20081008T065443-878@post.gmane.org>
References: <20080908115101.GE20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:59338 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694AbYJHHFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 03:05:09 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1KnT6V-0005Gv-1t
	for netdev@vger.kernel.org; Wed, 08 Oct 2008 07:05:03 +0000
Received: from bkjung8.etri.re.kr ([129.254.186.210])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2008 07:05:03 +0000
Received: from gauri by bkjung8.etri.re.kr with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2008 07:05:03 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf <at> suug.ch> writes:

> 
> This patch implements a very basic cgroup subsystem which allows
> assigning classids to cgroups. It also adds a trivial classifier
> to filter packets based on that classid and map them to classes.
> 
> The classifier should cover the most common use case and will work
> without any configuration.  Additionaly it might make sense to add
> a cgroup meta ematch to allow  for more sophisticated setups.
> 
> I've taken over the idea of inheriting the classid of cgroup parents
> from the patchset posted by Ranjit Manomohan <ranjitm <at> google.com>.
> 
> Comments welcome.
> 

Hello
I've done your patch to kernel-2.6.27-rc7.
Then I've got much of fails of compiling kernel.
What is your base kernel of this patch?
If there are any other patchs or programs for using your net_cls class,
Would you let me know?


