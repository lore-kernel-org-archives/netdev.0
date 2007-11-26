From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Mon, 26 Nov 2007 12:25:44 +1100
Message-ID: <200711261225.44415.rusty@rustcorp.com.au>
References: <20071122343.446909000@suse.de> <200711231129.25982.rusty@rustcorp.com.au> <adaprxyrrv0.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41763 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755281AbXKZBZq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Nov 2007 20:25:46 -0500
In-Reply-To: <adaprxyrrv0.fsf@cisco.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 26 November 2007 07:29:39 Roland Dreier wrote:
>  > Yes, and if a symbol is already used by multiple modules, it's
>  > generically useful.  And if so, why restrict it to in-tree modules?
>
> I agree that we shouldn't make things too hard for out-of-tree
> modules, but I disagree with your first statement: there clearly is a
> large class of symbols that are used by multiple modules but which are
> not generically useful -- they are only useful by a certain small class
> of modules.

If it is so clear, you should be able to easily provide examples?

Rusty.

