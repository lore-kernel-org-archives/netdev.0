From: Chei-yol Kim <gauri@etri.re.kr>
Subject: Re: [PATCH] =?utf-8?b?cGt0X3NjaGVkOg==?= Control group classifier
Date: Tue, 14 Oct 2008 11:56:09 +0000 (UTC)
Message-ID: <loom.20081014T115257-383@post.gmane.org>
References: <20081013155715.GZ20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:57475 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755261AbYJNL4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 07:56:31 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1KpiVg-0007kL-Ta
	for netdev@vger.kernel.org; Tue, 14 Oct 2008 11:56:25 +0000
Received: from bkjung8.etri.re.kr ([129.254.186.210])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 11:56:20 +0000
Received: from gauri by bkjung8.etri.re.kr with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 11:56:20 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf <at> suug.ch> writes:

> 
> This patch implements a very basic cgroup subsystem which allows
> assigning classids to cgroups. It also adds a trivial classifier
> to filter packets based on that classid and map them to classes.
> 

In order to test your patch, I need more programs such as iproute-x.x.x 
package modified for using your cgroup classifier.
You seem to test your code now. Please send me additional code and patch for 
testing environments.

Help me!

Your sincerely.


