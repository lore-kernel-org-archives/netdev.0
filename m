From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: [Bugme-new] [Bug 14336] New: [Pardus] Soft Lockup Problem with  Attansic Ethernet Card
Date: Tue, 6 Oct 2009 18:33:45 -0500
Message-ID: <869D6DF1-7AA5-46B9-81E4-DBA5D21603B4@gmail.com>
References: <bug-14336-10286@http.bugzilla.kernel.org/> <20091006155502.f3fc86d9.akpm@linux-foundation.org> <3d54862b0910061601iba25b87hfba151f71d6ce4ef@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v753.1)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: Erdem ARTAN <badibere@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f217.google.com ([209.85.219.217]:45347 "EHLO
	mail-ew0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933472AbZJFXeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 19:34:31 -0400
In-Reply-To: <3d54862b0910061601iba25b87hfba151f71d6ce4ef@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct 6, 2009, at 6:01 PM, Erdem ARTAN wrote:

> Yesterday, there wasn't any problem but 3 days ago there was same  
> problem.
>
> While there wasn't any problem, if I'm not wrong, both atl1c and  
> atl1e modules were loaded on boot. But, If I try to load atl1e now,  
> nothing changes.

The pci_id says your chip is an L1c.  Jie Yang is the maintainer of  
the atl1c driver and is cc'd.

Jay
