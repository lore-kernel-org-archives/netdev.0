From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net-sched 00/06: dynamically sized class hashes v2
Date: Thu, 3 Jul 2008 18:46:01 +0200
Message-ID: <20080703164601.GB2637@ami.dom.local>
References: <20080703151600.26225.3394.sendpatchset@localhost.localdomain> <20080703161403.GA2637@ami.dom.local> <486CF9BC.9090202@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devik@cdi.cz
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:50695 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbYGCQod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 12:44:33 -0400
Received: by yx-out-2324.google.com with SMTP id 8so289803yxm.1
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2008 09:44:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <486CF9BC.9090202@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 03, 2008 at 06:09:32PM +0200, Patrick McHardy wrote:
...
>> BTW: I wonder why cbq and htb have "common", while hfsc "cl_common"?
>
> Consistency, HFSC uses cl_ as prefix for many (unfortunately
> not all) class members.
>

BTW, BTW: I've just started to understand this "common" idea (I hope).
So if it's planned for some other (not searching) fields common for
classes, then of course, this name is quite sensible (maybe only a bit
too long for dereferencing).

Jarek P.
