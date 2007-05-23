From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Running multiple concurrent TCP stacks
Date: Wed, 23 May 2007 15:22:51 -0700
Message-ID: <20070523152251.0f12cbd7@localhost>
References: <103513710705231459l49add2a6xa9c4609d11e478a2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Tony Petz" <agoston.petz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:46257 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755741AbXEWWW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 18:22:58 -0400
In-Reply-To: <103513710705231459l49add2a6xa9c4609d11e478a2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 May 2007 16:59:02 -0500
"Tony Petz" <agoston.petz@gmail.com> wrote:

> I'm working on a research project that requires two simultaneously
> running but independent TCP implementations.  Searching the archives I
> was only able to come up with this:
> http://www.spinics.net/lists/linux-net/msg09064.html
> 
> I was wondering if anyone had any insight into the problem, or knew of
> a good place to start looking at how to load two copies of TCP stack,
> probably bound to two different interfaces for simplicity.
> 
> Any advice appreciated...
> -tony

Do it in UML or other virtualization environment
