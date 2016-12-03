From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] samples, bpf: Refactor; Add automated
 tests for cgroups
Date: Sat, 03 Dec 2016 16:08:21 -0500 (EST)
Message-ID: <20161203.160821.896715378505245197.davem@davemloft.net>
References: <20161202104201.GA9217@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com
To: sargun@sargun.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37314 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750789AbcLCVI1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 16:08:27 -0500
In-Reply-To: <20161202104201.GA9217@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sargun Dhillon <sargun@sargun.me>
Date: Fri, 2 Dec 2016 02:42:03 -0800

> These two patches are around refactoring out some old, reusable code from the 
> existing test_current_task_under_cgroup_user test, and adding a new, automated 
> test.
> 
> There is some generic cgroupsv2 setup & cleanup code, given that most 
> environment still don't have it setup by default. With this code, we're able
> to pretty easily add an automated test for future cgroupsv2 functionality.

Series applied, thanks.
