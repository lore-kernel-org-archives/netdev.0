From: Georgi Chorbadzhiyski <gf@unixsol.org>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x173/0x1a0()
Date: Fri, 04 Apr 2008 13:01:43 +0300
Message-ID: <47F5FC87.504@unixsol.org>
References: <20080402224137.GB25768@curie-int.orbis-terrarum.net> <20080403211913.3a0c1d00.akpm@linux-foundation.org> <200804041150.34046.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Robin H. Johnson" <robbat2@gentoo.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.unixsol.org ([193.110.159.2]:49724 "EHLO ns.unixsol.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027AbYDDKBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 06:01:44 -0400
In-Reply-To: <200804041150.34046.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Around 04/04/08 12:50, Rafael J. Wysocki scribbled:
> On Friday, 4 of April 2008, Andrew Morton wrote:
>> (cc netdev)
>>
>> (and Rafael - I assume 2.6.24 didn't do this..)
>>
>> On Wed, 2 Apr 2008 15:41:37 -0700 "Robin H. Johnson" <robbat2@gentoo.org> wrote:
> 
> That's http://bugzilla.kernel.org/show_bug.cgi?id=10346 , I think. 
> 
> Robin, please add yourself to the CC list in the bugzilla entry above.

No idea about 2.6.24 behavior. The kernel I was using before
upgrading to 2.6.25-rc6 was 2.6.21-rc7.

-- 
Georgi Chorbadzhiyski
http://georgi.unixsol.org/
